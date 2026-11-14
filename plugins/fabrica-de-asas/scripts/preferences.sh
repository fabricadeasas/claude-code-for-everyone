#!/usr/bin/env bash
#
# Keeps the Fábrica de Asas rules installed in the user's rules folder
# (~/.claude/rules/fabrica-de-asas/), where Claude Code loads them natively at
# the start of every session, with no size cap.
#
# The plugin ships the rules in ./rules. This script copies them to the rules
# folder according to the student's choices, stored in ${CLAUDE_PLUGIN_DATA}/config:
#
#   preferences = on | off          off removes the folder, so only the student's own CLAUDE.md applies
#   updates     = auto | ask | manual
#                 auto   copies every new version as soon as the plugin brings it
#                 ask    keeps the accepted version and asks the student at session start
#                 manual keeps the accepted version until the student asks to update
#
# Usage:
#   preferences.sh session-start          SessionStart hook: sync and print the hook JSON
#   preferences.sh status                 human-readable state
#   preferences.sh diff                   what changes between the installed and the new version
#   preferences.sh apply                  install the version the plugin brings now
#   preferences.sh decline                do not ask again about the version the plugin brings now
#   preferences.sh on | off               turn the Fábrica preferences on or off
#   preferences.sh updates <mode>         auto | ask | manual
#
# Rules written by this script take effect in the NEXT session: Claude Code
# reads the rules folder before SessionStart hooks run.

set -u

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

# Converts a Windows path (C:\Users\...) to the form Git Bash expects; no-op elsewhere.
to_unix_path() {
    if [ -n "$1" ] && command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$1"
    else
        printf '%s' "$1"
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(to_unix_path "${CLAUDE_PLUGIN_ROOT:-$SCRIPT_DIR/..}")"
SOURCE_DIR="$PLUGIN_ROOT/rules"
CONFIG_HOME="$(to_unix_path "${CLAUDE_CONFIG_DIR:-$HOME/.claude}")"
TARGET_DIR="$CONFIG_HOME/rules/fabrica-de-asas"
# Fallback matches the data folder Claude Code creates for fabrica-de-asas@fabricadeasas.
DATA_DIR="$(to_unix_path "${CLAUDE_PLUGIN_DATA:-$CONFIG_HOME/plugins/data/fabrica-de-asas-fabricadeasas}")"
CONFIG_FILE="$DATA_DIR/config"

MARKER="FABRICA_DE_ASAS_ATIVO"
SKILL="fabrica-de-asas:preferencias"

# ---------------------------------------------------------------------------
# Config (key=value lines, so no JSON parser is needed)
# ---------------------------------------------------------------------------

PREFERENCES="on"
UPDATES="auto"
INSTALLED=""
DECLINED=""

load_config() {
    [ -f "$CONFIG_FILE" ] || return 0
    local key value
    while IFS='=' read -r key value || [ -n "$key" ]; do
        value="${value%$'\r'}"
        case "$key" in
            preferences) PREFERENCES="$value" ;;
            updates) UPDATES="$value" ;;
            installed) INSTALLED="$value" ;;
            declined) DECLINED="$value" ;;
        esac
    done < "$CONFIG_FILE"
}

save_config() {
    mkdir -p "$DATA_DIR" || return 1
    printf 'preferences=%s\nupdates=%s\ninstalled=%s\ndeclined=%s\n' \
        "$PREFERENCES" "$UPDATES" "$INSTALLED" "$DECLINED" > "$CONFIG_FILE.tmp" &&
        mv -f "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

# ---------------------------------------------------------------------------
# Rules
# ---------------------------------------------------------------------------

# Fingerprint of a rules folder: file names and contents, line endings ignored.
rules_hash() {
    local dir="$1" file
    [ -d "$dir" ] || { echo ""; return; }
    for file in "$dir"/*.md; do
        [ -f "$file" ] || continue
        printf '%s\n' "${file##*/}"
        tr -d '\r' < "$file"
    done | cksum | cut -d' ' -f1
}

# Refuses to touch anything that is not our own folder.
assert_safe_target() {
    case "$TARGET_DIR" in
        */rules/fabrica-de-asas) return 0 ;;
        *) echo "Refusing to write outside the rules folder: $TARGET_DIR" >&2; return 1 ;;
    esac
}

# Copies the plugin rules into place atomically (temp folder, then swap).
install_rules() {
    assert_safe_target || return 1
    [ -d "$SOURCE_DIR" ] || { echo "Plugin rules not found in $SOURCE_DIR" >&2; return 1; }
    local staging="$TARGET_DIR.staging"
    rm -rf "$staging"
    mkdir -p "$staging" &&
        cp "$SOURCE_DIR"/*.md "$staging"/ &&
        rm -rf "$TARGET_DIR" &&
        mv "$staging" "$TARGET_DIR" || return 1
    INSTALLED="$(rules_hash "$SOURCE_DIR")"
    DECLINED=""
    save_config
}

remove_rules() {
    assert_safe_target || return 1
    rm -rf "$TARGET_DIR" "$TARGET_DIR.staging"
    INSTALLED=""
    save_config
}

# ---------------------------------------------------------------------------
# SessionStart hook output
# ---------------------------------------------------------------------------

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# $1 = context for Claude, $2 = optional notice shown to the student.
emit() {
    local context="$1" notice="${2:-}"
    printf '{'
    if [ -n "$notice" ]; then
        printf '"systemMessage":"%s",' "$(json_escape "$notice")"
    fi
    printf '"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
        "$(json_escape "$context")"
}

active_context() {
    printf '%s: as preferências da Fábrica de Asas (pasta ~/.claude/rules/fabrica-de-asas/) estão ativas nesta conversa. Atualizações: %s.' \
        "$MARKER" "$UPDATES"
}

session_start() {
    load_config

    if [ "$PREFERENCES" = "off" ]; then
        [ -d "$TARGET_DIR" ] && remove_rules
        emit "As preferências da Fábrica de Asas estão desligadas por escolha da pessoa. Siga só o CLAUDE.md dela. Para religar, use a skill $SKILL."
        return
    fi

    local available
    available="$(rules_hash "$SOURCE_DIR")"

    if [ ! -d "$TARGET_DIR" ] || [ -z "$INSTALLED" ]; then
        if install_rules; then
            emit "As preferências da Fábrica de Asas acabaram de ser instaladas e só passam a valer a partir da próxima conversa. Se fizer sentido, avise a pessoa disso uma vez, em uma frase. Na mesma ocasião, confira se a atualização automática do plugin está ligada, como explica a skill $SKILL (seção \"Atualização do plugin\"), e ofereça ligar se não estiver." \
                "Fábrica de Asas: preferências instaladas. Elas valem a partir da próxima conversa."
        else
            emit "Não foi possível instalar as preferências da Fábrica de Asas na pasta ~/.claude/rules/fabrica-de-asas/. Avise a pessoa em linguagem simples e ofereça investigar com a skill $SKILL." \
                "Fábrica de Asas: não consegui instalar as preferências."
        fi
        return
    fi

    if [ "$INSTALLED" = "$available" ]; then
        emit "$(active_context)"
        return
    fi

    case "$UPDATES" in
        ask)
            if [ "$DECLINED" = "$available" ]; then
                emit "$(active_context)"
            else
                emit "$(active_context) Há uma versão nova das preferências da Fábrica de Asas, e a pessoa pediu para ser consultada antes de atualizar. Na sua primeira resposta desta conversa, pergunte em uma frase se ela quer trazer as novidades agora e ofereça mostrar o que mudou. Para mostrar, aplicar ou recusar, use a skill $SKILL." \
                    "Fábrica de Asas: há uma atualização das preferências."
            fi
            ;;
        manual)
            emit "$(active_context) Existe uma versão nova das preferências, mas a pessoa escolheu atualizar só quando pedir. Não ofereça a atualização por conta própria."
            ;;
        *)
            if install_rules; then
                emit "$(active_context) As preferências acabaram de ser atualizadas e as novidades valem a partir da próxima conversa. Se a pessoa perguntar o que mudou, use a skill $SKILL." \
                    "Fábrica de Asas: preferências atualizadas. As novidades valem a partir da próxima conversa."
            else
                emit "$(active_context) A atualização automática das preferências falhou. Avise a pessoa em linguagem simples e ofereça investigar com a skill $SKILL." \
                    "Fábrica de Asas: não consegui atualizar as preferências."
            fi
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Commands used by the preferencias skill (plain text output for Claude)
# ---------------------------------------------------------------------------

status() {
    load_config
    local available installed_now state
    available="$(rules_hash "$SOURCE_DIR")"
    installed_now="$(rules_hash "$TARGET_DIR")"
    if [ "$PREFERENCES" = "off" ]; then
        state="off"
    elif [ ! -d "$TARGET_DIR" ]; then
        state="not-installed"
    elif [ "$INSTALLED" = "$available" ]; then
        state="up-to-date"
    else
        state="update-available"
    fi
    echo "preferences=$PREFERENCES"
    echo "updates=$UPDATES"
    echo "state=$state"
    echo "edited_by_hand=$([ -n "$INSTALLED" ] && [ -d "$TARGET_DIR" ] && [ "$installed_now" != "$INSTALLED" ] && echo yes || echo no)"
    echo "rules_folder=$TARGET_DIR"
    echo "plugin_rules=$SOURCE_DIR"
    echo "config_file=$CONFIG_FILE"
}

show_diff() {
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Nothing installed yet; every file in $SOURCE_DIR is new."
        return 0
    fi
    diff -ru --strip-trailing-cr "$TARGET_DIR" "$SOURCE_DIR" && echo "No differences."
    return 0
}

set_updates() {
    case "${1:-}" in
        auto | ask | manual) ;;
        *) echo "Use: updates auto | ask | manual" >&2; return 1 ;;
    esac
    load_config
    UPDATES="$1"
    DECLINED=""
    save_config && echo "updates=$UPDATES"
}

main() {
    case "${1:-}" in
        session-start) session_start ;;
        status) status ;;
        diff) show_diff ;;
        apply)
            load_config
            [ "$PREFERENCES" = "off" ] && { echo "Preferences are off; run 'on' first." >&2; return 1; }
            install_rules && echo "Installed. Takes effect in the next session."
            ;;
        decline)
            load_config
            DECLINED="$(rules_hash "$SOURCE_DIR")"
            save_config && echo "Will not ask again about this version."
            ;;
        on)
            load_config
            PREFERENCES="on"
            install_rules && echo "On. Takes effect in the next session."
            ;;
        off)
            load_config
            PREFERENCES="off"
            remove_rules && echo "Off. Takes effect in the next session."
            ;;
        updates) set_updates "${2:-}" ;;
        *)
            echo "Use: session-start | status | diff | apply | decline | on | off | updates <auto|ask|manual>" >&2
            return 1
            ;;
    esac
}

main "$@"
