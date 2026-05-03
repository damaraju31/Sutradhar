#!/usr/bin/env bash
# Context Health Score — Locked Evaluator (v2, manifest-driven)
# Measures context hierarchy health using a project-specific manifest.
# Pure bash + python3 (for JSON). No LLM. Deterministic. Ungameable.
#
# Usage: bash ~/.claude/skills/project-init/scripts/context-health-score.sh [OPTIONS]
# Options:
#   --json       Output JSON (default: human-readable)
#   --verbose    Show per-file details
#   --log        Append result to .claude/context/_health_history.log
#
# Exit codes:
#   0 = success (score computed)
#   1 = error (missing prerequisites like python3)
#   2 = no context files found (not bootstrapped)
#   3 = manifest missing (caller should generate it)
#   4 = manifest stale (structure changed, caller should regenerate)
set -uo pipefail

# ── Parse args ───────────────────────────────────────────────────────────────
OUTPUT_JSON=false
VERBOSE=false
LOG_RESULT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --json)    OUTPUT_JSON=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --log)     LOG_RESULT=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Prerequisites ────────────────────────────────────────────────────────────
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 required for JSON parsing" >&2
  exit 1
fi

# ── Check: bootstrapped? ────────────────────────────────────────────────────
if [ ! -d ".claude/rules" ]; then
  if [ "$OUTPUT_JSON" = true ]; then
    echo '{"status":"not_bootstrapped","score":0,"message":"No .claude/rules/ directory. Run /project-bootstrap first."}'
  else
    echo "No context hierarchy found. Run /project-bootstrap first." >&2
  fi
  exit 2
fi

RULE_COUNT=$(find .claude/rules -name "*.md" ! -name "context-protocol.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$RULE_COUNT" -eq 0 ]; then
  if [ "$OUTPUT_JSON" = true ]; then
    echo '{"status":"not_bootstrapped","score":0,"message":"No domain rule files found."}'
  else
    echo "No domain rule files found." >&2
  fi
  exit 2
fi

# ── Check: manifest exists? ─────────────────────────────────────────────────
MANIFEST=".claude/context/_score_manifest.json"
if [ ! -f "$MANIFEST" ]; then
  if [ "$OUTPUT_JSON" = true ]; then
    echo '{"status":"manifest_missing","score":0,"message":"Score manifest not found. Generate it first."}'
  else
    echo "Score manifest not found at $MANIFEST. Generate it to enable scoring." >&2
  fi
  exit 3
fi

# Validate manifest is parseable JSON
if ! python3 -c "import json; json.load(open('$MANIFEST'))" 2>/dev/null; then
  echo "Error: $MANIFEST is not valid JSON" >&2
  exit 1
fi

# ── Check: manifest stale? ──────────────────────────────────────────────────
# Compare current directory structure hash against manifest's stored hash
STORED_HASH=$(python3 -c "
import json
m = json.load(open('$MANIFEST'))
print(m.get('structure_hash', ''))
" 2>/dev/null)

# Compute current structure hash using the manifest's own language extensions
LANG_EXTENSIONS=$(python3 -c "
import json
m = json.load(open('$MANIFEST'))
exts = m.get('language', {}).get('file_extensions', ['.py'])
print(' '.join(['-name \"*' + e + '\"' for e in exts]))
" 2>/dev/null)

# Build the find command for current structure
CURRENT_HASH=$(eval "find . -type f \( $LANG_EXTENSIONS \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' -not -path '*/build/*' -not -path '*/dist/*' \
  -not -path '*/.claude/*' 2>/dev/null" \
  | sed 's|^\./||' | grep '/' | cut -d'/' -f1 | sort | uniq -c | sort \
  | md5 2>/dev/null || md5sum 2>/dev/null | cut -d' ' -f1)

if [ -n "$STORED_HASH" ] && [ -n "$CURRENT_HASH" ] && [ "$STORED_HASH" != "$CURRENT_HASH" ]; then
  if [ "$OUTPUT_JSON" = true ]; then
    echo '{"status":"manifest_stale","score":0,"message":"Project structure changed since manifest was generated."}'
  else
    echo "Manifest is stale (project structure changed). Regenerate it." >&2
  fi
  exit 4
fi

# ── Read manifest into scoring variables ─────────────────────────────────────
# Use python3 to extract values, write to temp file, then source it
_MANIFEST_VARS=$(mktemp)
python3 -c "
import json

m = json.load(open('.claude/context/_score_manifest.json'))

source_domains = [d for d in m.get('domains', []) if d.get('category') == 'source']
domain_names = [d['name'] for d in source_domains]
domain_paths = {d['name']: d.get('paths', []) for d in source_domains}
domain_thresholds = {d['name']: d.get('freshness_threshold_days', 14) for d in source_domains}

print('SOURCE_DOMAIN_COUNT=' + str(len(source_domains)))
print('SOURCE_DOMAIN_NAMES=\"' + ' '.join(domain_names) + '\"')

lang = m.get('language', {})
file_exts = lang.get('file_extensions', ['.py'])
includes = ' '.join(['--include=*' + e for e in file_exts])
print('GREP_INCLUDES=\"' + includes + '\"')

func_patterns = lang.get('function_patterns', ['def %s'])
func_parts = [p.replace('%s', '') for p in func_patterns]
print('FUNC_GREP_PREFIX=\"' + '|'.join(func_parts) + '\"')

class_patterns = lang.get('class_patterns', ['class %s'])
class_parts = [p.replace('%s', '') for p in class_patterns]
print('CLASS_GREP_PREFIX=\"' + '|'.join(class_parts) + '\"')

skip = m.get('accuracy', {}).get('skip_sections', ['## Provenance', '## Limitations'])
print('SKIP_SECTIONS=\"' + '|'.join(skip) + '\"')

comp = m.get('completeness', {})
print('REQ_SUMMARY=' + ('1' if comp.get('require_summary', True) else '0'))
print('REQ_PROVENANCE=' + ('1' if comp.get('require_provenance', True) else '0'))
print('REQ_LIMITATIONS=' + ('1' if comp.get('require_limitations_in_rules', True) else '0'))
print('REQ_EVIDENCE=' + ('1' if comp.get('require_evidence_in_adrs', True) else '0'))

for name, days in domain_thresholds.items():
    print('THRESHOLD_' + name + '=' + str(days))

for name, paths in domain_paths.items():
    dirs = [p.replace('/**', '').replace('/*', '') for p in paths]
    print('SEARCHDIR_' + name + '=\"' + ' '.join(dirs) + '\"')
" > "$_MANIFEST_VARS" 2>/dev/null

if [ ! -s "$_MANIFEST_VARS" ]; then
  echo "Error: Failed to parse manifest" >&2
  rm -f "$_MANIFEST_VARS"
  exit 1
fi

# shellcheck disable=SC1090
source "$_MANIFEST_VARS"
rm -f "$_MANIFEST_VARS"

HAS_GIT=false
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  HAS_GIT=true
fi

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 1: COVERAGE (weight 0.25)
# Do source domains have matching rule files?
# ══════════════════════════════════════════════════════════════════════════════

COV_COVERED=0
COV_MISSING=""

for domain in $SOURCE_DOMAIN_NAMES; do
  found=false

  # Check exact name match
  if [ -f ".claude/rules/${domain}.md" ]; then
    found=true
  fi

  # Check rules with matching paths: frontmatter
  if [ "$found" = false ]; then
    search_dir_var="SEARCHDIR_${domain}"
    search_dir="${!search_dir_var:-$domain}"
    for rule in .claude/rules/*.md; do
      [ -f "$rule" ] || continue
      [ "$(basename "$rule")" = "context-protocol.md" ] && continue
      if head -10 "$rule" | grep -q "${domain}/" 2>/dev/null; then
        found=true
        break
      fi
    done
  fi

  if [ "$found" = true ]; then
    COV_COVERED=$((COV_COVERED + 1))
  else
    COV_MISSING="$COV_MISSING $domain"
  fi
done

if [ "$SOURCE_DOMAIN_COUNT" -gt 0 ]; then
  COV_SCORE=$((COV_COVERED * 100 / SOURCE_DOMAIN_COUNT))
else
  COV_SCORE=100
fi

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 2: FRESHNESS (weight 0.30)
# Are context files updated after their source code was modified?
# Uses Provenance dates as primary signal (Agent B's enhancement).
# ══════════════════════════════════════════════════════════════════════════════

FRESH_TOTAL=0
FRESH_OK=0
FRESH_STALE_FILES=""

for rule in .claude/rules/*.md; do
  [ -f "$rule" ] || continue
  [ "$(basename "$rule")" = "context-protocol.md" ] && continue
  FRESH_TOTAL=$((FRESH_TOTAL + 1))

  # Determine domain from filename or paths frontmatter
  domain=$(basename "$rule" .md)

  # Get threshold for this domain (default 14 days)
  threshold_var="THRESHOLD_${domain}"
  threshold_days="${!threshold_var:-14}"
  threshold_secs=$((threshold_days * 86400))

  # Get context file last-updated date from Provenance section (primary signal)
  ctx_date=""
  if grep -q "## Provenance" "$rule" 2>/dev/null; then
    # Extract most recent provenance date (YYYY-MM-DD format, last non-comment line in Provenance)
    ctx_date=$(sed -n '/## Provenance/,/^## /p' "$rule" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1)
  fi

  # Convert to epoch
  ctx_epoch=""
  if [ -n "$ctx_date" ]; then
    ctx_epoch=$(date -j -f "%Y-%m-%d" "$ctx_date" +%s 2>/dev/null || date -d "$ctx_date" +%s 2>/dev/null)
  fi

  # Fallback: git log on the context file itself
  if [ -z "$ctx_epoch" ] && [ "$HAS_GIT" = true ]; then
    ctx_epoch=$(git log -1 --format=%ct -- "$rule" 2>/dev/null)
  fi

  # Fallback: file mtime
  if [ -z "$ctx_epoch" ]; then
    ctx_epoch=$(stat -f %m "$rule" 2>/dev/null || stat -c %Y "$rule" 2>/dev/null)
  fi

  # Get source last-modified date
  src_epoch=""
  search_dir_var="SEARCHDIR_${domain}"
  search_dir="${!search_dir_var:-$domain}"

  if [ -d "$search_dir" ]; then
    # Primary: git log for the domain directory
    if [ "$HAS_GIT" = true ]; then
      src_epoch=$(git log -1 --format=%ct -- "${search_dir}/" 2>/dev/null)
    fi
    # Fallback: _modifications.log
    if [ -z "$src_epoch" ] && [ -f ".claude/context/_modifications.log" ]; then
      local_date=$(grep "| ${domain} |" .claude/context/_modifications.log 2>/dev/null | tail -1 | cut -d'|' -f1 | tr -d ' ')
      if [ -n "$local_date" ]; then
        src_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$local_date" +%s 2>/dev/null || date -d "$local_date" +%s 2>/dev/null)
      fi
    fi
  fi

  # Compare
  if [ -n "$src_epoch" ] && [ -n "$ctx_epoch" ]; then
    delta=$((src_epoch - ctx_epoch))
    if [ "$delta" -gt "$threshold_secs" ]; then
      days_stale=$((delta / 86400))
      FRESH_STALE_FILES="$FRESH_STALE_FILES ${rule}:${days_stale}d"
    else
      FRESH_OK=$((FRESH_OK + 1))
    fi
  else
    # Can't determine — assume fresh
    FRESH_OK=$((FRESH_OK + 1))
  fi
done

# Also check component files
if [ -d ".claude/context/components" ]; then
  for comp in .claude/context/components/*.md; do
    [ -f "$comp" ] || continue
    FRESH_TOTAL=$((FRESH_TOTAL + 1))

    # Parse provenance for date
    ctx_date=$(sed -n '/## Provenance/,/^## /p' "$comp" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1)
    ctx_epoch=""
    if [ -n "$ctx_date" ]; then
      ctx_epoch=$(date -j -f "%Y-%m-%d" "$ctx_date" +%s 2>/dev/null || date -d "$ctx_date" +%s 2>/dev/null)
    fi
    if [ -z "$ctx_epoch" ] && [ "$HAS_GIT" = true ]; then
      ctx_epoch=$(git log -1 --format=%ct -- "$comp" 2>/dev/null)
    fi
    if [ -z "$ctx_epoch" ]; then
      ctx_epoch=$(stat -f %m "$comp" 2>/dev/null || stat -c %Y "$comp" 2>/dev/null)
    fi

    # Compare against most recent project commit
    src_epoch=""
    if [ "$HAS_GIT" = true ]; then
      src_epoch=$(git log -1 --format=%ct 2>/dev/null)
    fi

    if [ -n "$src_epoch" ] && [ -n "$ctx_epoch" ]; then
      delta=$((src_epoch - ctx_epoch))
      if [ "$delta" -gt 604800 ]; then  # 7 days default for components
        days_stale=$((delta / 86400))
        FRESH_STALE_FILES="$FRESH_STALE_FILES ${comp}:${days_stale}d"
      else
        FRESH_OK=$((FRESH_OK + 1))
      fi
    else
      FRESH_OK=$((FRESH_OK + 1))
    fi
  done
fi

if [ "$FRESH_TOTAL" -gt 0 ]; then
  FRESH_SCORE=$((FRESH_OK * 100 / FRESH_TOTAL))
else
  FRESH_SCORE=100
fi

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 3: ACCURACY (weight 0.30)
# Do verifiable references match actual code?
# Skips ## Provenance and ## Limitations sections (Agent B's enhancement).
# ══════════════════════════════════════════════════════════════════════════════

ACC_VERIFIED=0
ACC_REFUTED=0
ACC_UNVERIFIABLE=0
ACC_REFUTED_DETAILS=""

# Collect all context files
CTX_FILES=""
for f in .claude/rules/*.md; do
  [ -f "$f" ] && [ "$(basename "$f")" != "context-protocol.md" ] && CTX_FILES="$CTX_FILES $f"
done
if [ -d ".claude/context/components" ]; then
  for f in .claude/context/components/*.md; do [ -f "$f" ] && CTX_FILES="$CTX_FILES $f"; done
fi
if [ -d ".claude/context/decisions" ]; then
  for f in .claude/context/decisions/*.md; do [ -f "$f" ] && CTX_FILES="$CTX_FILES $f"; done
fi

for ctx_file in $CTX_FILES; do
  [ -f "$ctx_file" ] || continue

  # Determine search scope from manifest
  domain=""
  search_scope="."
  for d in $SOURCE_DOMAIN_NAMES; do
    search_dir_var="SEARCHDIR_${d}"
    sd="${!search_dir_var:-$d}"
    if head -10 "$ctx_file" | grep -q "${d}" 2>/dev/null || echo "$ctx_file" | grep -q "${d}"; then
      if [ -d "$sd" ]; then
        search_scope="$sd"
        domain="$d"
        break
      fi
    fi
  done

  # Extract content EXCLUDING skip sections (Provenance, Limitations)
  # Use python3 for reliable section filtering
  content=$(python3 -c "
import sys
skip_headers = '$SKIP_SECTIONS'.split('|')
skip = False
for line in open('$ctx_file'):
    stripped = line.strip()
    if any(stripped.startswith(h) for h in skip_headers):
        skip = True
        continue
    if skip and stripped.startswith('## '):
        skip = False
    if not skip:
        print(line, end='')
" 2>/dev/null)

  # Extract backtick-wrapped references from non-skipped content
  refs=$(echo "$content" | grep -oE '`[a-zA-Z_][a-zA-Z0-9_./()\-]*`' 2>/dev/null | tr -d '`' | sort -u)

  # Extract file path references
  file_refs=$(echo "$content" | grep -oE '[a-zA-Z0-9_][a-zA-Z0-9_/.\-]+\.(py|ts|tsx|js|jsx|go|rs|java|rb|kt|swift|sh)' 2>/dev/null | sort -u)

  # Verify backtick references
  for ref in $refs; do
    [ -z "$ref" ] && continue
    [ ${#ref} -lt 3 ] && continue
    # Skip common non-code words
    case "$ref" in true|false|null|none|None|True|False|yes|no|TODO|FIXME|NOTE|HACK|source|domain|project) continue ;; esac

    if [[ "$ref" == *"/"* && "$ref" == *"."* ]]; then
      # File path
      if [ -f "$ref" ]; then ACC_VERIFIED=$((ACC_VERIFIED + 1))
      else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${ref}:file"; fi

    elif [[ "$ref" == *"/"* ]]; then
      # Directory path
      if [ -d "$ref" ] || [ -d "${ref%/}" ]; then ACC_VERIFIED=$((ACC_VERIFIED + 1))
      else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${ref}:dir"; fi

    elif [[ "$ref" =~ ^[A-Z][a-zA-Z0-9]+$ ]]; then
      # PascalCase — class name
      if grep -rq "$CLASS_GREP_PREFIX${ref}" "$search_scope" $GREP_INCLUDES 2>/dev/null; then
        ACC_VERIFIED=$((ACC_VERIFIED + 1))
      else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${ref}:class"; fi

    elif [[ "$ref" == *"()"* || "$ref" == *"()" ]]; then
      # Function reference
      fname="${ref%%(*}"
      if grep -rq "${fname}" "$search_scope" $GREP_INCLUDES 2>/dev/null; then
        ACC_VERIFIED=$((ACC_VERIFIED + 1))
      else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${ref}:func"; fi

    elif [[ "$ref" == *"_"* || "$ref" == *"."* ]]; then
      # Identifier with underscore or dot
      if grep -rq "${ref}" "$search_scope" $GREP_INCLUDES 2>/dev/null; then
        ACC_VERIFIED=$((ACC_VERIFIED + 1))
      else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${ref}:ident"; fi

    else
      ACC_UNVERIFIABLE=$((ACC_UNVERIFIABLE + 1))
    fi
  done

  # Verify file path references (skip those already counted in backtick refs)
  for fref in $file_refs; do
    [ -z "$fref" ] && continue
    echo "$refs" | grep -q "$fref" 2>/dev/null && continue
    if [ -f "$fref" ]; then ACC_VERIFIED=$((ACC_VERIFIED + 1))
    else ACC_REFUTED=$((ACC_REFUTED + 1)); ACC_REFUTED_DETAILS="$ACC_REFUTED_DETAILS ${ctx_file}:${fref}:file"; fi
  done
done

ACC_TOTAL=$((ACC_VERIFIED + ACC_REFUTED))
if [ "$ACC_TOTAL" -gt 0 ]; then
  ACC_SCORE=$((ACC_VERIFIED * 100 / ACC_TOTAL))
else
  ACC_SCORE=100
fi

# ══════════════════════════════════════════════════════════════════════════════
# DIMENSION 4: COMPLETENESS (weight 0.15)
# Are context files properly filled in (not just scaffolded)?
# Checks: summaries, provenance, limitations, evidence (Agent B's enhancements).
# ══════════════════════════════════════════════════════════════════════════════

COMP_TOTAL=0
COMP_FILLED=0
COMP_MISSING_DETAILS=""

for ctx_file in $CTX_FILES; do
  [ -f "$ctx_file" ] || continue

  # Check: summary line (non-placeholder > line after title)
  if [ "$REQ_SUMMARY" = "1" ]; then
    COMP_TOTAL=$((COMP_TOTAL + 1))
    if grep -q "^>" "$ctx_file" 2>/dev/null; then
      # Check it's not a placeholder
      summary=$(grep "^>" "$ctx_file" | head -1)
      if echo "$summary" | grep -qv "{{" 2>/dev/null && [ ${#summary} -gt 5 ]; then
        COMP_FILLED=$((COMP_FILLED + 1))
      else
        COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:summary_placeholder"
      fi
    else
      COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:no_summary"
    fi
  fi

  # Check: provenance section with at least one non-comment entry
  if [ "$REQ_PROVENANCE" = "1" ]; then
    COMP_TOTAL=$((COMP_TOTAL + 1))
    if grep -q "## Provenance" "$ctx_file" 2>/dev/null; then
      # Check for at least one non-comment line after ## Provenance
      prov_content=$(sed -n '/## Provenance/,/^## /p' "$ctx_file" | grep -v "^#\|^<!--\|^$" | head -1)
      if [ -n "$prov_content" ]; then
        COMP_FILLED=$((COMP_FILLED + 1))
      else
        COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:provenance_empty"
      fi
    else
      COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:no_provenance"
    fi
  fi

  # Check: limitations section (rule files only)
  if [ "$REQ_LIMITATIONS" = "1" ]; then
    if echo "$ctx_file" | grep -q ".claude/rules/" 2>/dev/null; then
      COMP_TOTAL=$((COMP_TOTAL + 1))
      if grep -q "## Limitations" "$ctx_file" 2>/dev/null; then
        lim_content=$(sed -n '/## Limitations/,/^## /p' "$ctx_file" | grep -v "^#\|^<!--\|^$" | head -1)
        if [ -n "$lim_content" ]; then
          COMP_FILLED=$((COMP_FILLED + 1))
        else
          COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:limitations_empty"
        fi
      else
        COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:no_limitations"
      fi
    fi
  fi

  # Check: evidence field (ADR files only)
  if [ "$REQ_EVIDENCE" = "1" ]; then
    if echo "$ctx_file" | grep -q "decisions/ADR-" 2>/dev/null; then
      COMP_TOTAL=$((COMP_TOTAL + 1))
      if grep -q "^\\*\\*Evidence\\*\\*:" "$ctx_file" 2>/dev/null; then
        evidence=$(grep "^\\*\\*Evidence\\*\\*:" "$ctx_file" | head -1)
        if echo "$evidence" | grep -qv "{{" 2>/dev/null && [ ${#evidence} -gt 15 ]; then
          COMP_FILLED=$((COMP_FILLED + 1))
        else
          COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:evidence_placeholder"
        fi
      else
        COMP_MISSING_DETAILS="$COMP_MISSING_DETAILS ${ctx_file}:no_evidence"
      fi
    fi
  fi
done

if [ "$COMP_TOTAL" -gt 0 ]; then
  COMP_SCORE=$((COMP_FILLED * 100 / COMP_TOTAL))
else
  COMP_SCORE=100
fi

# ══════════════════════════════════════════════════════════════════════════════
# COMPOSITE SCORE
# ══════════════════════════════════════════════════════════════════════════════

COMPOSITE=$(( (COV_SCORE * 25 + FRESH_SCORE * 30 + ACC_SCORE * 30 + COMP_SCORE * 15) / 100 ))
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# ── Output ───────────────────────────────────────────────────────────────────

if [ "$OUTPUT_JSON" = true ]; then
  python3 -c "
import json
result = {
    'status': 'scored',
    'score': $COMPOSITE,
    'timestamp': '$TIMESTAMP',
    'dimensions': {
        'coverage': {
            'score': $COV_SCORE,
            'weight': 0.25,
            'source_domains': $SOURCE_DOMAIN_COUNT,
            'covered': $COV_COVERED,
            'missing': '$(echo $COV_MISSING | xargs)'.split() if '$(echo $COV_MISSING | xargs)' else []
        },
        'freshness': {
            'score': $FRESH_SCORE,
            'weight': 0.30,
            'total_files': $FRESH_TOTAL,
            'fresh': $FRESH_OK,
            'stale_files': '$(echo $FRESH_STALE_FILES | xargs)'.split() if '$(echo $FRESH_STALE_FILES | xargs)' else []
        },
        'accuracy': {
            'score': $ACC_SCORE,
            'weight': 0.30,
            'verified': $ACC_VERIFIED,
            'refuted': $ACC_REFUTED,
            'unverifiable': $ACC_UNVERIFIABLE,
            'refuted_refs': '$(echo $ACC_REFUTED_DETAILS | xargs)'.split() if '$(echo $ACC_REFUTED_DETAILS | xargs)' else []
        },
        'completeness': {
            'score': $COMP_SCORE,
            'weight': 0.15,
            'total_checks': $COMP_TOTAL,
            'passed': $COMP_FILLED,
            'missing': '$(echo $COMP_MISSING_DETAILS | xargs)'.split() if '$(echo $COMP_MISSING_DETAILS | xargs)' else []
        }
    }
}
print(json.dumps(result, indent=2))
"
else
  echo ""
  echo "Context Health Score: ${COMPOSITE}/100"
  echo ""
  echo "  Coverage:     ${COV_SCORE}  (${COV_COVERED}/${SOURCE_DOMAIN_COUNT} source domains have rules)"
  echo "  Freshness:    ${FRESH_SCORE}  (${FRESH_OK}/${FRESH_TOTAL} context files up-to-date)"
  echo "  Accuracy:     ${ACC_SCORE}  (${ACC_VERIFIED}/$((ACC_VERIFIED + ACC_REFUTED)) verifiable references confirmed)"
  echo "  Completeness: ${COMP_SCORE}  (${COMP_FILLED}/${COMP_TOTAL} quality checks passed)"
  echo ""

  if [ "$VERBOSE" = true ]; then
    echo "  Details:"
    for domain in $COV_MISSING; do
      [ -z "$domain" ] && continue
      echo "    [coverage] Missing rule: ${domain}/"
    done
    for entry in $FRESH_STALE_FILES; do
      [ -z "$entry" ] && continue
      echo "    [freshness] Stale: ${entry}"
    done
    for entry in $ACC_REFUTED_DETAILS; do
      [ -z "$entry" ] && continue
      echo "    [accuracy] Broken: ${entry}"
    done
    for entry in $COMP_MISSING_DETAILS; do
      [ -z "$entry" ] && continue
      echo "    [completeness] Missing: ${entry}"
    done
    echo ""
  fi
fi

# ── Log ──────────────────────────────────────────────────────────────────────

if [ "$LOG_RESULT" = true ]; then
  mkdir -p .claude/context
  echo "${TIMESTAMP} | score=${COMPOSITE} | coverage=${COV_SCORE} | freshness=${FRESH_SCORE} | accuracy=${ACC_SCORE} | completeness=${COMP_SCORE} | files=${FRESH_TOTAL} | domains=${SOURCE_DOMAIN_COUNT}" \
    >> .claude/context/_health_history.log
fi

exit 0
