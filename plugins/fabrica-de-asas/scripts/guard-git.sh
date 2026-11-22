#!/usr/bin/env bash
#
# PreToolUse guard for the Bash and PowerShell tools.
#
# The people this plugin serves cannot judge git commands, so the commands
# that lose work for good are blocked here, outside the model, instead of
# relying on an instruction:
#
#   - rewriting or deleting versions already sent to the cloud (force push, push --delete);
#   - throwing away work that was never saved (reset --hard, clean -f, checkout/restore
#     over uncommitted changes, stash drop/clear, branch -D);
#   - saving a .env file (passwords and keys) into the history.
#
# Each git command is read on its own and judged in the repository it actually
# touches, not in the folder of the conversation: "git -C <dir>", "cd <dir>" /
# "Set-Location <dir>" earlier in the same command, and simple variables set
# earlier in it (DIR=...; cd "$DIR") are followed. Text inside quotes, comments and
# heredoc or here-string bodies that only feed a file are not commands.
#
# Exit code 2 blocks the tool call; stderr goes back to Claude as the reason.
# Anything that cannot be parsed is allowed: the guard must never block normal work.

set -u

INPUT="$(cat)"

to_unix_path() {
    if [ -n "$1" ] && command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$1"
    else
        printf '%s' "$1"
    fi
}

# Extracts a top-level string field from the hook JSON without a JSON parser.
# Escaped backslashes are parked first, so "C:\\new" does not turn into a line break.
json_field() {
    printf '%s' "$INPUT" |
        grep -o -E "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" |
        head -n 1 |
        sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//" |
        sed -e 's/\\\\/\x01/g' -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\\r//g' -e 's/\\"/"/g' -e 's/\x01/\\/g'
}

COMMAND="$(json_field command)"
CWD="$(json_field cwd)"

# Not a git command: nothing to check.
printf '%s' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]|$)' || exit 0

block() {
    printf '%s\n' "$1" >&2
    exit 2
}

# Separator between the tokens of one segment in the lexer output.
SEP=$'\037'

# ---------------------------------------------------------------------------
# CommandLexer: turns the command into segments (split on newlines, ;, &&, ||,
# |, parentheses and braces), one per line, with tokens separated by SEP.
# Quotes are honoured, so a commit message with ";" inside stays one token.
# Backslashes are kept as they are (Windows paths).
# ---------------------------------------------------------------------------

CommandLexer::segments() {
    printf '%s' "$COMMAND" | awk -v SEP="$SEP" '
        BEGIN { RS = "\001" }
        function emit_token() {
            if (has) { segment = (count ? segment SEP : "") token; count++ }
            token = ""; has = 0
        }
        function emit_segment() {
            emit_token()
            if (count) print segment
            segment = ""; count = 0
        }
        {
            # Pass 1: drop heredoc and here-string bodies that only feed a file;
            # keep them when they feed a shell, since then they run.
            lines = split($0, line, "\n"); text = ""; until_word = ""; until_ps = ""
            for (i = 1; i <= lines; i++) {
                current = line[i]; sub(/\r$/, "", current)
                if (until_word != "") {
                    probe = current; if (dash) sub(/^\t+/, "", probe)
                    if (probe == until_word) until_word = ""
                    continue
                }
                if (until_ps != "") {
                    if (index(current, until_ps) == 1) { current = substr(current, 3); until_ps = "" }
                    else continue
                }
                text = text current "\n"
                probe = current; gsub(/<<</, "\002\002\002", probe)
                feeds_shell = (probe ~ /(^|[^[:alnum:]_.\/-])(bash|sh|zsh|dash|ksh|pwsh|powershell)(\.exe)?([ \t]+-[[:alnum:]-]+)*[ \t]*<</)
                if (match(probe, /<<-?[ \t]*["\047]?[A-Za-z_][A-Za-z0-9_]*["\047]?/)) {
                    if (!feeds_shell) {
                        word = substr(probe, RSTART, RLENGTH)
                        dash = (substr(word, 3, 1) == "-")
                        sub(/^<<-?[ \t]*/, "", word); gsub(/["\047]/, "", word)
                        until_word = word
                    }
                } else if (current ~ /@\047[ \t]*$/) {
                    until_ps = "\047@"
                } else if (current ~ /@"[ \t]*$/) {
                    until_ps = "\"@"
                }
            }

            # Pass 2: split into segments and tokens.
            length_text = length(text); token = ""; has = 0; segment = ""; count = 0; quote = ""
            for (i = 1; i <= length_text; i++) {
                c = substr(text, i, 1); next_c = substr(text, i + 1, 1)
                if (quote == "\047") {
                    if (c == "\047") quote = ""; else token = token (c == "\n" ? " " : c)
                    continue
                }
                if (quote == "\"") {
                    if ((c == "\\" || c == "`") && next_c == "\"") { token = token "\""; i++ }
                    else if (c == "\"") quote = ""
                    else token = token (c == "\n" ? " " : c)
                    continue
                }
                if (c == "\047" || c == "\"") { quote = c; has = 1; continue }
                if (c == "#" && !has && (i == 1 || substr(text, i - 1, 1) ~ /[ \t\n;&|(){}]/)) {
                    while (i < length_text && substr(text, i + 1, 1) != "\n") i++
                    continue
                }
                if (c == "\\" && next_c == "\n") { i++; emit_token(); continue }
                if (c == "$" && next_c == "{") {
                    close_at = index(substr(text, i), "}")
                    if (close_at) { token = token substr(text, i, close_at); has = 1; i += close_at - 1; continue }
                }
                if (c == " " || c == "\t") { emit_token(); continue }
                if (c == "&" && (substr(text, i - 1, 1) ~ /[<>]/ || next_c == ">")) { token = token c; has = 1; continue }
                if (c ~ /[\n;&|(){}]/) { emit_segment(); continue }
                token = token c; has = 1
            }
            emit_segment()
        }'
}

# ---------------------------------------------------------------------------
# Workspace: the folder each segment runs in, following cd / Set-Location and
# simple variables set earlier in the same command. An empty DIR means the
# folder can no longer be known; segments after that are not judged.
# ---------------------------------------------------------------------------

declare -A VARS=()
declare -A UNKNOWN_VARS=()
DIR="$(to_unix_path "$CWD")"
[ -n "$DIR" ] || DIR="$PWD"

# Expands $NAME, ${NAME}, $env:NAME and ~ with what is known; fails if something is unknown.
Workspace::expand() {
    local s="$1" whole name value
    case "$s" in
        "~") s="$HOME" ;;
        "~/"* | "~\\"*) s="$HOME/${s:2}" ;;
    esac
    while [[ "$s" =~ \$(\{)?(env:)?([A-Za-z_][A-Za-z0-9_]*)(\})? ]]; do
        whole="${BASH_REMATCH[0]}"
        name="${BASH_REMATCH[3]}"
        if [ -n "${UNKNOWN_VARS[$name]+x}" ]; then
            return 1
        elif [ -n "${VARS[$name]+x}" ]; then
            value="${VARS[$name]}"
        elif [ "$name" = PWD ]; then
            value="$DIR"
        elif [ "$name" != OLDPWD ] && [ -n "${!name+x}" ]; then
            value="${!name}"
        else
            return 1
        fi
        s="${s/"$whole"/$value}"
    done
    printf '%s' "$s"
}

# Resolves a path against a base folder.
Workspace::resolve() {
    local path
    path="$(Workspace::expand "$1")" || return 1
    [ -n "$path" ] && [ -n "$2" ] || return 1
    case "$path" in
        [A-Za-z]:*) path="$(to_unix_path "$path")" ;;
        /*) ;;
        *) path="$2/$path" ;;
    esac
    printf '%s' "$path"
}

Workspace::remember() {
    local value
    if value="$(Workspace::expand "$2")"; then
        VARS[$1]="$value"
        unset 'UNKNOWN_VARS[$1]'
    else
        UNKNOWN_VARS[$1]=1
        unset 'VARS[$1]'
    fi
}

# Handles segments that change the folder or set a variable; returns 0 when it did.
Workspace::track() {
    local first="${TOKENS[0]:-}" n=${#TOKENS[@]} i target=""
    case "${first,,}" in
        cd | pushd | chdir | set-location | sl | push-location)
            i=1
            while [ "$i" -lt "$n" ]; do
                case "${TOKENS[$i],,}" in
                    -path | -literalpath) target="${TOKENS[$((i + 1))]:-}"; break ;;
                    -l | -p | -e | -@ | --) ;;
                    *) target="${TOKENS[$i]}"; break ;;
                esac
                i=$((i + 1))
            done
            if [ -z "$target" ]; then
                DIR="$HOME"
            elif [ "$target" = "-" ]; then
                DIR=""
            else
                DIR="$(Workspace::resolve "$target" "$DIR")" || DIR=""
            fi
            return 0
            ;;
        popd | pop-location)
            DIR=""
            return 0
            ;;
        export | declare | local | typeset | readonly)
            [ "$n" -eq 2 ] && [[ "${TOKENS[1]}" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || return 1
            Workspace::remember "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
            return 0
            ;;
    esac
    # NAME=value alone (a NAME=value before a command only applies to that command).
    if [ "$n" -eq 1 ] && [[ "$first" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
        Workspace::remember "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        return 0
    fi
    # PowerShell: $name = value
    if [[ "$first" =~ ^\$([A-Za-z_][A-Za-z0-9_]*)$ ]] && [ "${TOKENS[1]:-}" = "=" ] && [ "$n" -eq 3 ]; then
        Workspace::remember "${BASH_REMATCH[1]}" "${TOKENS[2]}"
        return 0
    fi
    return 1
}

# ---------------------------------------------------------------------------
# GitGuard: the checks, one git command at a time, in the repository it touches.
# ---------------------------------------------------------------------------

REPO=""

git_here() {
    git -C "$REPO" "$@" 2>/dev/null
}

PLAIN="Explique para a pessoa em linguagem simples, sem jargão de git, o que você ia fazer e o caminho seguro. Para voltar atrás, prefira sempre uma versão nova que desfaz a antiga (git revert)."

# Finds git in TOKENS; sets SUB_INDEX (index of the subcommand) and SEGMENT_DIR
# (the folder after any "git -C <dir>", empty when it cannot be known).
GitGuard::parse() {
    SUB_INDEX=-1
    SEGMENT_DIR="$DIR"
    local i=0 n=${#TOKENS[@]} name found=no
    while [ "$i" -lt "$n" ]; do
        name="${TOKENS[$i]##*[/\\]}"
        name="${name%.exe}"
        [ "$name" = git ] && { found=yes; break; }
        i=$((i + 1))
    done
    [ "$found" = yes ] || return 1
    i=$((i + 1))
    while [ "$i" -lt "$n" ]; do
        case "${TOKENS[$i]}" in
            -C)
                if [ -n "$SEGMENT_DIR" ]; then
                    SEGMENT_DIR="$(Workspace::resolve "${TOKENS[$((i + 1))]:-}" "$SEGMENT_DIR")" || SEGMENT_DIR=""
                fi
                i=$((i + 2))
                ;;
            -c) i=$((i + 2)) ;;
            -*) i=$((i + 1)) ;;
            *) SUB_INDEX=$i; return 0 ;;
        esac
    done
    return 1
}

# Points REPO at the repository the command touches; fails when it is unknown.
GitGuard::enter_repo() {
    [ -n "$SEGMENT_DIR" ] || return 1
    REPO="$(git -C "$SEGMENT_DIR" rev-parse --show-toplevel 2>/dev/null)" || return 1
    [ -n "$REPO" ]
}

# True when any argument after the subcommand matches the extended regex.
GitGuard::has_arg() {
    local i=$((SUB_INDEX + 1)) n=${#TOKENS[@]}
    while [ "$i" -lt "$n" ]; do
        [[ "${TOKENS[$i]}" =~ $1 ]] && return 0
        i=$((i + 1))
    done
    return 1
}

GitGuard::has_unsaved_changes() {
    [ -n "$(git_here status --porcelain --untracked-files=no)" ]
}

# 1. Versions already in the cloud are never rewritten or deleted.
GitGuard::check_push() {
    if GitGuard::has_arg '^(--force([=-].*)?|-f|--mirror|--delete|-d|--prune)$' ||
        GitGuard::has_arg '^[+:].'; then
        block "Bloqueado pelo plugin Fábrica de Asas: esse envio reescreveria ou apagaria versões que já estão guardadas na nuvem, e elas não voltariam. Para desfazer algo que já foi enviado, crie uma versão nova que desfaz a antiga (git revert) e envie normalmente. Se o envio foi recusado porque a nuvem tem novidades, busque-as antes (git pull) e envie de novo. $PLAIN"
    fi
}

# 2. Unsaved work is never thrown away.
GitGuard::check_discard() {
    local sub="$1" discards=no
    case "$sub" in
        reset)
            GitGuard::has_arg '^--hard$' &&
                block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez o trabalho que ainda não virou versão e pode descartar versões que ainda não foram enviadas. Para voltar atrás, crie uma versão nova que desfaz a antiga (git revert). Para trazer um arquivo como estava antes, salve a versão atual primeiro e depois restaure só aquele arquivo. $PLAIN"
            ;;
        clean)
            GitGuard::has_arg '^(-[[:alpha:]]*f[[:alpha:]]*|--force)$' &&
                block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez os arquivos que nunca foram guardados em nenhuma versão. Se algum arquivo realmente sobra, apague só ele, com o ok da pessoa, depois de dizer qual é. $PLAIN"
            ;;
        stash)
            case "${TOKENS[$((SUB_INDEX + 1))]:-}" in
                drop | clear) block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez um trabalho guardado à parte. $PLAIN" ;;
            esac
            ;;
        branch)
            if GitGuard::has_arg '^-D$' || { GitGuard::has_arg '^(--delete|-d)$' && GitGuard::has_arg '^(--force|-f)$'; }; then
                block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga uma linha de trabalho mesmo que ela tenha versões que não existem em nenhum outro lugar. $PLAIN"
            fi
            ;;
        checkout)
            GitGuard::has_arg '^(--|\.)$' && discards=yes
            ;;
        restore)
            if ! { GitGuard::has_arg '^(--staged|-S)$' && ! GitGuard::has_arg '^(--worktree|-W)$'; }; then
                discards=yes
            fi
            ;;
    esac
    if [ "$discards" = yes ] && GitGuard::enter_repo && GitGuard::has_unsaved_changes; then
        block "Bloqueado pelo plugin Fábrica de Asas: há mudanças que ainda não viraram versão, e esse comando escreveria por cima delas sem volta. Salve uma versão do estado atual primeiro (git add + git commit) e só depois traga o arquivo antigo. Assim dá para voltar ao estado de agora se precisar. $PLAIN"
    fi
}

# 3. Passwords and keys never go into the history.
GitGuard::check_secrets() {
    GitGuard::enter_repo || return 0
    local secrets
    secrets="$(
        { git_here ls-files --cached; git_here ls-files --others --exclude-standard; } |
            grep -E '(^|/)\.env(\.[^/]*)?$' |
            grep -Ev '\.(example|sample|template|dist)$' |
            sort -u
    )"
    if [ -n "$secrets" ]; then
        block "Bloqueado pelo plugin Fábrica de Asas: estes arquivos costumam guardar senhas e chaves e iriam junto na versão (e para a nuvem): $(printf '%s' "$secrets" | tr '\n' ' ')
Antes de salvar a versão: acrescente-os ao .gitignore e, se algum já estava sendo guardado, tire-o das versões sem apagar o arquivo (git rm --cached <arquivo>). Se uma senha já foi enviada para a nuvem, avise a pessoa que ela precisa ser trocada. $PLAIN"
    fi
}

GitGuard::check_segment() {
    GitGuard::parse || return 0
    local sub="${TOKENS[$SUB_INDEX]}"
    case "$sub" in
        push) GitGuard::check_push ;;
        reset | clean | stash | branch | checkout | restore) GitGuard::check_discard "$sub" ;;
        add | commit) GitGuard::check_secrets ;;
    esac
}

GitGuard::check_command() {
    local segment
    while IFS= read -r segment; do
        IFS="$SEP" read -r -a TOKENS <<< "$segment"
        [ ${#TOKENS[@]} -gt 0 ] || continue
        Workspace::track && continue
        GitGuard::check_segment
    done < <(CommandLexer::segments)
}

GitGuard::check_command
exit 0
