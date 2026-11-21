#!/usr/bin/env bash
# Tests for scripts/guard-git.sh (the git safety guard).
#
# Builds throwaway repositories in a temporary folder: a clean one, one with
# unsaved changes and one with a .env file. Then feeds the guard hook inputs and
# checks the exit code (0 = allowed, 2 = blocked), including commands that touch
# a repository other than the conversation folder.
#
# Usage: bash tests/guard-git.test.sh [path/to/guard-git.sh]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GUARD="${1:-$HERE/../scripts/guard-git.sh}"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null

for d in clean dirty secret example; do
  mkdir -p "$T/$d"
  (cd "$T/$d" && git init -q -b main && git config user.email t@t && git config user.name t && echo a > a && git add a && git commit -qm first)
done
echo changed > "$T/dirty/a"
echo "KEY=x" > "$T/secret/.env"
echo "KEY=" > "$T/example/.env.example"

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//$'\n'/\\n}"; s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

PASS=0; FAILED=0
run() { # cwd-repo command expected-exit
  local cwd json rc ok label
  cwd="$(cygpath -m "$T/$1" 2>/dev/null || echo "$T/$1")"
  json=$(printf '{"tool_name":"Bash","tool_input":{"command":"%s"},"cwd":"%s"}' "$(json_escape "$2")" "$cwd")
  printf '%s' "$json" | bash "$GUARD" >/dev/null 2>&1; rc=$?
  if [ "$rc" = "$3" ]; then ok=ok; PASS=$((PASS + 1)); else ok=FAIL; FAILED=$((FAILED + 1)); fi
  label="${2//$'\n'/ ⏎ }"; label="${label//$T/<T>}"; label="${label//$(cygpath -w "$T" 2>/dev/null || echo "$T")/<T>}"
  printf '%-4s %-8s %-62.62s exit=%s (want %s)\n' "$ok" "$1" "$label" "$rc" "$3"
}
F=force; H=hard
D="$T/dirty"; C="$T/clean"; S="$T/secret"
SW="$(cygpath -w "$S" 2>/dev/null || echo "$S")"

echo "-- versions in the cloud"
run clean  "git push --$F"                            2
run clean  "git push -f origin feat"                  2
run clean  "git push --$F-with-lease"                 2
run clean  "git push origin +main"                    2
run clean  "git push origin :feat"                    2
run clean  "git push --delete origin feat"            2
run clean  "git push -u origin feat"                  0
run clean  "rm -f x && git push origin feat"          0

echo "-- unsaved work"
run clean  "git reset --$H"                           2
run clean  "git reset --soft HEAD~1"                  0
run clean  "git clean -fd"                            2
run clean  "git clean -n"                             0
run clean  "git stash drop"                           2
run clean  "git stash"                                0
run clean  "git branch -D feat"                       2
run clean  "git branch -d feat"                       0
run dirty  "git checkout -- a"                        2
run clean  "git checkout -- a"                        0
run dirty  "git restore a"                            2
run dirty  "git restore --staged a"                   0
run dirty  "git checkout feat"                        0

echo "-- passwords and keys"
run secret "git add ."                                2
run secret "git commit -m x"                          2
run example "git add ."                               0
run clean  "git commit -m x"                          0

echo "-- another folder"
run clean  "git -C \"$D\" checkout -- ."              2
run dirty  "git -C \"$C\" checkout -- ."              0
run clean  "cd \"$D\" && git restore a"               2
run dirty  "cd \"$C\" && git restore a"               0
run clean  "git -C \"$S\" add ."                      2
run secret "git -C \"$C\" commit -m x"                0
run secret "cd \"$C\"; git add ."                     0
run clean  "R=\"$S\"; git -C \"\$R\" commit -m x"     2
run clean  "Set-Location \"$SW\"; git add ."          2
run secret "git -C \"\$NOT_SET_ANYWHERE\" add ."      0
run clean  "git -C \"\$NOT_SET_ANYWHERE\" reset --$H" 2

echo "-- text that is not a command"
run clean  "git commit -m \"never run git reset --$H or git push --$F\"" 0
run clean  "cat > f.sh <<'EOF'
git push --$F
EOF"                                                  0
run clean  "bash <<'EOF'
git push --$F
EOF"                                                  2
run clean  "# git reset --$H"                         0

echo "== $PASS passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
