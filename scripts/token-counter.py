#!/usr/bin/env python3
"""
Token counter for Agent Team Framework.
Counts tokens in files using Anthropic API (exact) or character heuristic (approximate).

Usage:
  python3 scripts/token-counter.py file1.ts file2.ts ...
  python3 scripts/token-counter.py --from-task docs/tasks/TASK_003.md
  python3 scripts/token-counter.py --dir src/auth/

Output: JSON with per-file token counts, total, and context budget percentage.
"""

import sys
import os
import json
import glob as glob_mod


def count_tokens_heuristic(content: str, filepath: str) -> int:
    """Approximate token count based on content type."""
    ext = os.path.splitext(filepath)[1].lower()
    code_exts = {'.ts', '.tsx', '.js', '.jsx', '.py', '.go', '.rs', '.java', '.rb', '.swift', '.kt', '.cs', '.cpp', '.c', '.h'}
    structured_exts = {'.json', '.yaml', '.yml', '.toml', '.xml', '.html', '.css', '.scss'}

    chars = len(content)
    if ext in code_exts:
        return int(chars / 3.5)
    elif ext in structured_exts:
        return int(chars / 3.0)
    else:
        return int(chars / 4.0)


def count_tokens_api(content: str, model: str = "claude-sonnet-4-6") -> int:
    """Exact token count via Anthropic API. Returns -1 if unavailable."""
    try:
        import anthropic
        client = anthropic.Anthropic()
        response = client.messages.count_tokens(
            model=model,
            messages=[{"role": "user", "content": content}]
        )
        return response.input_tokens
    except Exception:
        return -1


def extract_files_from_task(task_path: str) -> list:
    """Extract file paths from a task file's Pre-Gathered Context section."""
    files = []
    try:
        with open(task_path, 'r') as f:
            content = f.read()
        in_context = False
        for line in content.split('\n'):
            if 'Pre-Gathered Context' in line or 'Files to Reference' in line:
                in_context = True
                continue
            if in_context and line.startswith('## '):
                break
            if in_context and ('/' in line or '.' in line):
                path = line.strip().lstrip('- ').lstrip('`').rstrip('`').strip()
                if os.path.isfile(path):
                    files.append(path)
    except Exception:
        pass
    return files


def main():
    files = []
    use_api = False

    args = sys.argv[1:]
    if '--api' in args:
        use_api = True
        args.remove('--api')

    if '--from-task' in args:
        idx = args.index('--from-task')
        if idx + 1 < len(args):
            files = extract_files_from_task(args[idx + 1])
            args = args[:idx] + args[idx+2:]

    if '--dir' in args:
        idx = args.index('--dir')
        if idx + 1 < len(args):
            dir_path = args[idx + 1]
            for ext in ['*.ts', '*.tsx', '*.js', '*.jsx', '*.py', '*.go', '*.rs', '*.java', '*.md']:
                files.extend(glob_mod.glob(os.path.join(dir_path, '**', ext), recursive=True))
            args = args[:idx] + args[idx+2:]

    # Remaining args are file paths or glob patterns
    for arg in args:
        if '*' in arg:
            files.extend(glob_mod.glob(arg, recursive=True))
        elif os.path.isfile(arg):
            files.append(arg)

    if not files:
        print(json.dumps({"error": "No files provided", "usage": "python3 token-counter.py file1.ts file2.ts ..."}))
        sys.exit(1)

    results = []
    total_tokens = 0
    method = "heuristic"

    for filepath in sorted(set(files)):
        try:
            with open(filepath, 'r', errors='replace') as f:
                content = f.read()

            byte_size = os.path.getsize(filepath)

            if use_api:
                tokens = count_tokens_api(content)
                if tokens >= 0:
                    method = "anthropic_api"
                else:
                    tokens = count_tokens_heuristic(content, filepath)
                    method = "heuristic"
            else:
                tokens = count_tokens_heuristic(content, filepath)

            results.append({
                "path": filepath,
                "bytes": byte_size,
                "tokens": tokens
            })
            total_tokens += tokens
        except Exception as e:
            results.append({"path": filepath, "error": str(e)})

    window_size = 200000
    output = {
        "files": results,
        "file_count": len(results),
        "total_tokens": total_tokens,
        "method": method,
        "pct_of_200k": round(total_tokens / window_size * 100, 1),
        "estimated_task_total": {
            "implementation": {"tokens": total_tokens * 7, "pct": round(total_tokens * 7 / window_size * 100, 1)},
            "review": {"tokens": total_tokens * 3, "pct": round(total_tokens * 3 / window_size * 100, 1)},
            "research": {"tokens": total_tokens * 2, "pct": round(total_tokens * 2 / window_size * 100, 1)}
        },
        "recommendation": ""
    }

    impl_pct = output["estimated_task_total"]["implementation"]["pct"]
    if impl_pct < 40:
        output["recommendation"] = "Fits comfortably in single context window"
    elif impl_pct < 70:
        output["recommendation"] = "Moderate — use plan-then-clear pattern for safety"
    elif impl_pct < 100:
        output["recommendation"] = "Tight — strongly recommend plan-then-clear or splitting into subtasks"
    else:
        output["recommendation"] = "EXCEEDS budget ({}%) — MUST split into {} subtasks".format(impl_pct, int(impl_pct / 60) + 1)

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
