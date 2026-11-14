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
# Exit code 2 blocks the tool call; stderr goes back to Claude as the reason.
# Anything that cannot be parsed is allowed: the guard must never block normal work.

set -u

INPUT="$(cat)"

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

# Not a git command: nothing to check.
printf '%s' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]|$)' || exit 0

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

exit 0
