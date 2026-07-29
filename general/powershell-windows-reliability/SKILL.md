---
name: powershell-windows-reliability
description: Execute and debug PowerShell commands reliably on Windows. Use when Codex runs native CLIs or scripts through PowerShell, handles Unicode or spaced paths and text encoding, resolves executables not on PATH, composes commands for persistent approval rules, or encounters quoting, mojibake, argument parsing, or shell mismatch failures.
---

# PowerShell Windows Reliability

Use one shell and one contract. Treat PowerShell parsing, native argv construction,
text encoding, sandbox approval, and application behavior as separate layers.

## Workflow

1. Identify the execution layer.
   - Assume the command runner already invokes PowerShell when its tool contract says so.
   - Do not wrap a command in another `pwsh -Command` unless a different PowerShell
     version, profile boundary, or persistent approval rule requires it.
   - Resolve missing executables with `Get-Command`. Use an explicit executable path when
     PATH is incomplete; use the workspace dependency resolver when the app supplies one.
   - Complete when the exact shell and executable paths are known.

2. Construct native arguments deliberately.
   - Invoke a quoted executable path with the call operator: `& 'C:\path\tool.exe' ...`.
   - Use single-quoted literal paths and `-LiteralPath` for PowerShell file cmdlets.
   - Keep each native command in its own command segment. Run independent reads in parallel
     through the orchestrator instead of joining them with `;`, pipes, or nested shells.
   - Never pass PowerShell-only parameters such as `-ErrorAction` to a native program.
   - Complete when PowerShell parsing produces the intended executable and argv.

3. Preserve the encoding boundary.
   - Default to UTF-8 for text reads and writes; distinguish terminal rendering from file
     corruption before changing a file.
   - Use `apply_patch` for manual source edits. Do not rewrite source through `Set-Content`,
     redirection, or shell-generated strings merely to repair encoding.
   - Change console and `$OutputEncoding` only when a native tool demonstrates an encoding
     mismatch, and scope that change to the command process.
   - Complete when the file decodes as intended and any native stdin/stdout boundary agrees.

4. Run the smallest diagnostic command.
   - Reproduce with one command and one path before adding filters, pipes, variables, or
     environment setup.
   - Classify failure as command resolution, PowerShell parse, native argv, encoding,
     sandbox/permission, network, or application failure. Change one layer at a time.
   - Do not interpret a non-zero exit from a search with no matches as shell failure.
   - Complete when the failing layer is supported by output, not guessed from symptoms.

5. Make approval requests stable.
   - Keep commands eligible for narrow prefix rules: one executable, fixed wrapper where
     practical, no unrelated status commands, pipes, substitutions, or wildcard expansion.
   - Request the narrowest reusable prefix. Never request an interpreter-only prefix that
     would authorize arbitrary code.
   - If a fixed wrapper exists for a repeated external operation, use it verbatim.
   - Complete when the command matches the intended approval scope and nothing broader.

6. Verify the outcome.
   - Check exit code and the output field that proves success.
   - After copying or packaging files, compare hashes or parse the produced artifact.
   - For long-running commands, retain the process identifier and wait for completion rather
     than launching a second copy.
   - Complete only when the requested state is observed, not merely when the shell accepted
     the command.

## Recipes

Read [references/recipes.md](references/recipes.md) when constructing a command involving
native CLIs, Unicode paths, encoding diagnostics, `rg`, JSON, explicit Python runtimes, or
persistent approval rules.

## Final Check

Before reporting completion, confirm all applicable facts:

- the shell and executable are explicit;
- literal paths survived parsing;
- no PowerShell parameter leaked into native argv;
- encoding was verified at the correct boundary;
- the exit code and semantic output were checked;
- approval scope is no broader than the operation.
