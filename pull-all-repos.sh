#!/usr/bin/env bash
#
# pull-all-repos.sh
# Find all Git repositories under one or more base directories and pull them.
#
# Safe defaults:
#   - Only pulls if the working tree is clean
#   - Uses --ff-only (fast-forward only, no merge commits)
#   - Skips repos that are not on a branch
#   - Logs everything
#
# Usage:
#   ./pull-all-repos.sh                 # search $HOME
#   ./pull-all-repos.sh /path/to/code   # search specific path
#   ./pull-all-repos.sh --force         # pull even if dirty (dangerous)
#   ./pull-all-repos.sh --rebase        # use pull --rebase instead of --ff-only

set -euo pipefail

# ---------- config ----------
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/pull-all-repos.log"
BASE_DIRS=()
FORCE=false
USE_REBASE=false
MAX_DEPTH=6          # how deep to search for .git directories
PARALLEL=false       # set true if you want parallel pulls (more load)

# ---------- helpers ----------
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
}

die() { log "ERROR: $*"; exit 1; }

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] [BASE_DIR...]

Options:
  --force     Pull even if working tree is dirty
  --rebase    Use 'git pull --rebase' instead of --ff-only
  -h, --help  Show this help

If no BASE_DIR is given, defaults to \$HOME.
EOF
  exit 0
}

# ---------- parse args ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    --rebase) USE_REBASE=true; shift ;;
    -h|--help) usage ;;
    --) shift; break ;;
    -*) die "Unknown option: $1" ;;
    *) BASE_DIRS+=("$1"); shift ;;
  esac
done

if [[ ${#BASE_DIRS[@]} -eq 0 ]]; then
  BASE_DIRS=("$HOME")
fi

mkdir -p "$(dirname "$LOG_FILE")"
log "=== Starting pull-all-repos ==="
log "Base directories: ${BASE_DIRS[*]}"
log "Force=$FORCE  Rebase=$USE_REBASE"

# ---------- find repos ----------
mapfile -t REPOS < <(
  for base in "${BASE_DIRS[@]}"; do
    [[ -d "$base" ]] || continue
    # Find directories that contain a .git folder or file
    find "$base" -maxdepth "$MAX_DEPTH" -type d -name .git -prune -print 2>/dev/null \
      | sed 's|/\.git$||'
  done | sort -u
)

log "Found ${#REPOS[@]} repositories"

# ---------- pull function ----------
pull_one() {
  local repo="$1"
  log "---- $repo ----"

  # Confirm it is a real git work tree
  if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "  Skipping: not a valid git work tree"
    return
  fi

  # Check if on a branch
  if ! git -C "$repo" symbolic-ref -q HEAD >/dev/null 2>&1; then
    log "  Skipping: detached HEAD"
    return
  fi

  # Check dirty working tree
  if ! $FORCE; then
    if ! git -C "$repo" diff --quiet --exit-code 2>/dev/null || \
       ! git -C "$repo" diff --cached --quiet --exit-code 2>/dev/null; then
      log "  Skipping: working tree is dirty (use --force to override)"
      return
    fi
  fi

  local pull_cmd=("git" "-C" "$repo" "pull" "--ff-only")
  if $USE_REBASE; then
    pull_cmd=("git" "-C" "$repo" "pull" "--rebase")
  fi

  # Capture output so we can show the real error
  local output
  if output=$("${pull_cmd[@]}" 2>&1); then
    log "  Success"
    [[ -n "$output" ]] && echo "$output" | sed 's/^/    /' | tee -a "$LOG_FILE"
  else
    log "  FAILED"
    echo "$output" | sed 's/^/    /' | tee -a "$LOG_FILE"
  fi
}

# ---------- run ----------
if [[ ${#REPOS[@]} -eq 0 ]]; then
  log "No repositories found. Done."
  exit 0
fi

if $PARALLEL; then
  # crude parallel with xargs (requires GNU xargs)
  export -f pull_one log
  export LOG_FILE FORCE USE_REBASE
  printf '%s\n' "${REPOS[@]}" | xargs -P 4 -I {} bash -c 'pull_one "$@"' _ {}
else
  for repo in "${REPOS[@]}"; do
    pull_one "$repo"
  done
fi

log "=== Finished ==="
echo "Log written to: $LOG_FILE"
