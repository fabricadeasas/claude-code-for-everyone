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
#   - saving a .env file (passwords and keys) into the history;
#   - changing production (main/master) by any path other than a pull request from dev
#     (production lock, on while the Fábrica preferences are on; the preferencias skill
#     can turn it off).
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
json_field() {
    printf '%s' "$INPUT" |
        grep -o -E "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" |
        head -n 1 |
        sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//" |
        sed -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

COMMAND="$(json_field command)"
CWD="$(json_field cwd)"

# Not a git or GitHub CLI command: nothing to check.
printf '%s' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])(git|gh)([[:space:]]|$)' || exit 0

matches() {
    printf '%s' "$COMMAND" | grep -Eq "$1"
}

git_here() {
    if [ -n "$CWD" ]; then
        git -C "$CWD" "$@" 2>/dev/null
    else
        git "$@" 2>/dev/null
    fi
}

has_unsaved_changes() {
    [ -n "$(git_here status --porcelain --untracked-files=no)" ]
}

block() {
    printf '%s\n' "$1" >&2
    exit 2
}

# A git invocation, with global options such as -C <dir> or -c key=value before the subcommand.
GIT='git([[:space:]]+-[Cc][[:space:]]+[^[:space:]]+|[[:space:]]+-[^[:space:]]+)*[[:space:]]+'

PLAIN="Explique para a pessoa em linguagem simples, sem jargão de git, o que você ia fazer e o caminho seguro. Para voltar atrás, prefira sempre uma versão nova que desfaz a antiga (git revert)."

# 1. Versions already in the cloud are never rewritten or deleted.
# Only the push itself is inspected, so flags of other chained commands (rm -f) do not count.
PUSH="$(printf '%s' "$COMMAND" | grep -oE "$GIT"'push([[:space:]][^;&|]*)?')"
if [ -n "$PUSH" ] &&
    printf '%s' "$PUSH" | grep -Eq '[[:space:]](--force([=-][^[:space:]]*)?|-f|--mirror|--delete|-d|--prune)([[:space:]]|$)|[[:space:]]\+[^[:space:]]+|[[:space:]]:[^[:space:]]+'; then
    block "Bloqueado pelo plugin Fábrica de Asas: esse envio reescreveria ou apagaria versões que já estão guardadas na nuvem, e elas não voltariam. Para desfazer algo que já foi enviado, crie uma versão nova que desfaz a antiga (git revert) e envie normalmente. Se o envio foi recusado porque a nuvem tem novidades, busque-as antes (git pull) e envie de novo. $PLAIN"
fi

# 2. Unsaved work is never thrown away.
if matches "$GIT"'reset([[:space:]][^;&|]*)?[[:space:]]--hard'; then
    block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez o trabalho que ainda não virou versão e pode descartar versões que ainda não foram enviadas. Para voltar atrás, crie uma versão nova que desfaz a antiga (git revert). Para trazer um arquivo como estava antes, salve a versão atual primeiro e depois restaure só aquele arquivo. $PLAIN"
fi

if matches "$GIT"'clean([[:space:]][^;&|]*)?[[:space:]]-[[:alpha:]]*f'; then
    block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez os arquivos que nunca foram guardados em nenhuma versão. Se algum arquivo realmente sobra, apague só ele, com o ok da pessoa, depois de dizer qual é. $PLAIN"
fi

if matches "$GIT"'stash[[:space:]]+(drop|clear)'; then
    block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga de vez um trabalho guardado à parte. $PLAIN"
fi

if matches "$GIT"'branch([[:space:]][^;&|]*)?[[:space:]](-D|--delete[[:space:]]+--force|--force[[:space:]]+--delete)([[:space:]]|$)'; then
    block "Bloqueado pelo plugin Fábrica de Asas: esse comando apaga uma linha de trabalho mesmo que ela tenha versões que não existem em nenhum outro lugar. $PLAIN"
fi

DISCARDS_FILES=no
if matches "$GIT"'checkout([[:space:]][^;&|]*)?[[:space:]](--|\.)([[:space:]]|$)'; then
    DISCARDS_FILES=yes
fi
if matches "$GIT"'restore([[:space:]]|$)' &&
    ! { matches '[[:space:]](--staged|-S)([[:space:]]|$)' && ! matches '[[:space:]](--worktree|-W)([[:space:]]|$)'; }; then
    DISCARDS_FILES=yes
fi
if [ "$DISCARDS_FILES" = yes ] && has_unsaved_changes; then
    block "Bloqueado pelo plugin Fábrica de Asas: há mudanças que ainda não viraram versão, e esse comando escreveria por cima delas sem volta. Salve uma versão do estado atual primeiro (git add + git commit) e só depois traga o arquivo antigo. Assim dá para voltar ao estado de agora se precisar. $PLAIN"
fi

# 3. Passwords and keys never go into the history.
if matches "$GIT"'(add|commit)([[:space:]]|$)'; then
    SECRETS="$(
        { git_here ls-files --cached; git_here ls-files --others --exclude-standard; } |
            grep -E '(^|/)\.env(\.[^/]*)?$' |
            grep -Ev '\.(example|sample|template|dist)$' |
            sort -u
    )"
    if [ -n "$SECRETS" ]; then
        block "Bloqueado pelo plugin Fábrica de Asas: estes arquivos costumam guardar senhas e chaves e iriam junto na versão (e para a nuvem): $(printf '%s' "$SECRETS" | tr '\n' ' ')
Antes de salvar a versão: acrescente-os ao .gitignore e, se algum já estava sendo guardado, tire-o das versões sem apagar o arquivo (git rm --cached <arquivo>). Se uma senha já foi enviada para a nuvem, avise a pessoa que ela precisa ser trocada. $PLAIN"
    fi
fi

# ---------------------------------------------------------------------------
# Production lock
#
# The command is split into segments (&&, ||, ;, |) and read in order, so a
# "git switch main && git merge dev" is judged on the branch it switches to.
# ---------------------------------------------------------------------------

PRODUCTION_MESSAGE="Bloqueado pelo plugin Fábrica de Asas: a linha main (ou master) é produção e só recebe versões por um pedido de junção (pull request) vindo da dev, com alerta e confirmação da pessoa, como explica a skill fabrica-de-asas:versionamento-publicar-prod. Salve e mande as versões na dev (git switch dev; se ela não existe, git switch -c dev) e, para publicar, siga aquela skill. Não tente outro caminho para mudar a main. $PLAIN"

# On unless the Fábrica preferences are off or the student turned the lock off.
ProductionLock::enabled() {
    local data_dir config
    data_dir="$(to_unix_path "${CLAUDE_PLUGIN_DATA:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/data/fabrica-de-asas-fabricadeasas}")"
    config="$data_dir/config"
    [ -f "$config" ] || return 0
    ! tr -d '\r' < "$config" | grep -Eq '^(preferences=off|production_lock=off)$'
}

ProductionLock::is_production() {
    case "${1#refs/heads/}" in
        main | master) return 0 ;;
        *) return 1 ;;
    esac
}

ProductionLock::is_work_line() {
    case "${1#*:}" in
        dev | develop) return 0 ;;
        *) return 1 ;;
    esac
}

# The branch exists in the cloud already (pushing it for the first time is allowed).
ProductionLock::remote_has() {
    git_here rev-parse --verify -q "refs/remotes/$1/${2#refs/heads/}" >/dev/null
}

ProductionLock::has_history() {
    git_here rev-parse --verify -q HEAD >/dev/null
}

# Splits a segment into TOKENS; sets TOOL (git|gh) and SUB_INDEX (index of the subcommand).
ProductionLock::parse() {
    read -r -a TOKENS <<< "$1"
    TOOL=""
    SUB_INDEX=-1
    local i=0 n=${#TOKENS[@]} name
    while [ "$i" -lt "$n" ]; do
        name="${TOKENS[$i]##*/}"
        name="${name%.exe}"
        case "$name" in
            git | gh) TOOL="$name"; break ;;
        esac
        i=$((i + 1))
    done
    [ -n "$TOOL" ] || return 1
    i=$((i + 1))
    while [ "$i" -lt "$n" ]; do
        case "${TOKENS[$i]}" in
            -C | -c | -R | --repo) i=$((i + 2)) ;;
            -*) i=$((i + 1)) ;;
            *) SUB_INDEX=$i; return 0 ;;
        esac
    done
    return 1
}

# Value of an option given as "--name value", "--name=value" or "-x value".
ProductionLock::option() {
    local long="$1" short="$2" i=$((SUB_INDEX + 1)) n=${#TOKENS[@]}
    while [ "$i" -lt "$n" ]; do
        case "${TOKENS[$i]}" in
            "$long"=*) printf '%s' "${TOKENS[$i]#*=}"; return 0 ;;
            "$long" | "$short") printf '%s' "${TOKENS[$((i + 1))]:-}"; return 0 ;;
        esac
        i=$((i + 1))
    done
    return 1
}

ProductionLock::check_push() {
    local i=$((SUB_INDEX + 1)) n=${#TOKENS[@]} token remote="" refspecs=() tags_only=no dst
    while [ "$i" -lt "$n" ]; do
        token="${TOKENS[$i]}"
        case "$token" in
            --all | --branches) block "$PRODUCTION_MESSAGE" ;;
            --tags) tags_only=yes ;;
            -o | --push-option | --repo | --receive-pack | --exec) i=$((i + 1)) ;;
            -*) ;;
            *) if [ -z "$remote" ]; then remote="$token"; else refspecs+=("$token"); fi ;;
        esac
        i=$((i + 1))
    done
    remote="${remote:-origin}"
    if [ ${#refspecs[@]} -eq 0 ]; then
        [ "$tags_only" = yes ] && return 0
        refspecs=("$BRANCH")
    fi
    for token in "${refspecs[@]}"; do
        dst="${token#+}"
        dst="${dst##*:}"
        [ "$dst" = "HEAD" ] && dst="$BRANCH"
        if ProductionLock::is_production "$dst" && ProductionLock::remote_has "$remote" "$dst"; then
            block "$PRODUCTION_MESSAGE"
        fi
    done
}

ProductionLock::check_pr_create() {
    local base head
    base="$(ProductionLock::option --base -B)" || base="$(git_here symbolic-ref --short refs/remotes/origin/HEAD)"
    base="${base#origin/}"
    base="${base:-main}"
    ProductionLock::is_production "$base" || return 0
    head="$(ProductionLock::option --head -H)" || head="$BRANCH"
    ProductionLock::is_work_line "$head" || block "$PRODUCTION_MESSAGE O pedido de junção para a main tem que sair da dev (gh pr create --base main --head dev)."
}

ProductionLock::check_segments() {
    BRANCH="$(git_here branch --show-current)"
    local segment sub target
    while IFS= read -r segment; do
        ProductionLock::parse "$segment" || continue
        sub="${TOKENS[$SUB_INDEX]}"
        if [ "$TOOL" = gh ]; then
            [ "$sub" = pr ] && [ "${TOKENS[$((SUB_INDEX + 1))]:-}" = create ] && ProductionLock::check_pr_create
            continue
        fi
        case "$sub" in
            switch | checkout)
                if target="$(ProductionLock::option --create -c)" ||
                    target="$(ProductionLock::option --force-create -C)" ||
                    target="$(ProductionLock::option --orphan --orphan)" ||
                    { [ "$sub" = checkout ] && { target="$(ProductionLock::option -b -b)" || target="$(ProductionLock::option -B -B)"; }; }; then
                    BRANCH="$target"
                elif printf '%s' "$segment" | grep -Eq '[[:space:]](--|\.)([[:space:]]|$)'; then
                    : # checkout of files: the branch does not change
                else
                    # The last argument is the branch; "-" means the previous one, which is unknown here.
                    target="${TOKENS[${#TOKENS[@]} - 1]}"
                    case "$target" in
                        -) BRANCH="" ;;
                        -* | "$sub") ;;
                        *) BRANCH="$target" ;;
                    esac
                fi
                ;;
            push) ProductionLock::check_push ;;
            commit | merge | cherry-pick | revert | am | rebase)
                printf '%s' "$segment" | grep -Eq '[[:space:]]--(abort|quit)([[:space:]]|$)' && continue
                if ProductionLock::is_production "$BRANCH" && ProductionLock::has_history; then
                    block "$PRODUCTION_MESSAGE"
                fi
                ;;
        esac
    done < <(printf '%s\n' "$COMMAND" | sed -E 's/(&&|\|\||;|\|)/\n/g')
}

# 4. Production lock: main/master only change through a pull request from dev.
ProductionLock::enabled || exit 0
ProductionLock::check_segments
exit 0
