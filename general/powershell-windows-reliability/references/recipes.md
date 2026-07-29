# PowerShell Reliability Recipes

## Shell And Executable Discovery

```powershell
$PSVersionTable.PSVersion
Get-Command rg -ErrorAction SilentlyContinue
Get-Command python -ErrorAction SilentlyContinue
```

When an executable is absent from PATH, invoke the known runtime directly:

```powershell
& 'C:\absolute\path\python.exe' -m py_compile 'route\experiment\evaluate.py'
```

Do not repeatedly retry the unresolved short name.

## Literal Paths

Use PowerShell cmdlets with `-LiteralPath` when a path may contain spaces, brackets,
wildcards, or non-ASCII characters:

```powershell
Get-Content -Raw -Encoding UTF8 -LiteralPath 'D:\研究\实验 [1]\结果.json'
Copy-Item -LiteralPath 'D:\研究\源文件.json' -Destination 'D:\研究\归档.json'
```

Invoke a native executable with the call operator:

```powershell
& 'C:\Users\name\.local\bin\kaggle.exe' kernels status 'owner/private-kernel'
```

Do not add `cmd /c`, Bash, or a second PowerShell unless the target program specifically
requires that shell.

## Ripgrep

Keep ripgrep flags in ripgrep syntax and PowerShell flags in PowerShell syntax:

```powershell
rg -n --glob '*.py' 'cosine_similarity|nonzero' 'route\v5.1.0'
Get-ChildItem -LiteralPath 'route\v5.1.0' -ErrorAction SilentlyContinue
```

Do not write this:

```powershell
rg 'pattern' 'route' -ErrorAction SilentlyContinue
```

Ripgrep exit code `1` means no matches; exit code `2` means an actual error.

## JSON And UTF-8

Read structured files through structured parsers:

```powershell
$value = Get-Content -Raw -Encoding UTF8 -LiteralPath 'result.json' | ConvertFrom-Json
$value.status
```

Before declaring mojibake or corruption, inspect bytes and a hash:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'result.json'
Format-Hex -LiteralPath 'result.json' | Select-Object -First 8
```

PowerShell 7 uses UTF-8 without BOM for normal text output, but native programs may use a
different console code page. Only when native stdin/stdout is proven mismatched, scope UTF-8
to that process:

```powershell
$utf8 = [System.Text.UTF8Encoding]::new($false)
$oldOutput = $OutputEncoding
$oldConsoleOut = [Console]::OutputEncoding
try {
    $OutputEncoding = $utf8
    [Console]::OutputEncoding = $utf8
    & 'C:\path\native-tool.exe' args
} finally {
    $OutputEncoding = $oldOutput
    [Console]::OutputEncoding = $oldConsoleOut
}
```

Use `apply_patch` for manual source changes instead of shell text rewriting.

## Native Argument Arrays

For dynamic arguments, build an array so each item remains one argv element:

```powershell
$arguments = @('kernels', 'push', '-p', 'kaggle\private-experiment-runner')
& 'C:\Users\name\.local\bin\kaggle.exe' @arguments
```

Do not build one interpolated command string and execute it with `Invoke-Expression`.

## Approval-Friendly Commands

Persistent approval matching is most reliable when the command is a single stable segment:

```powershell
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -File 'C:\fixed\runner.ps1'
```

Keep timestamps, output filtering, downloads, and status checks in separate tool calls. Avoid
pipes, `;`, substitutions, variables, and wildcards in a command intended to match a stored
prefix rule. Prefer a fixed wrapper that validates destination, privacy, and remote slug.

## Failure Classification

| Symptom | First check |
|---|---|
| command not recognized | `Get-Command` and explicit executable path |
| unexpected token or unterminated string | PowerShell quoting and nesting |
| native tool rejects an option | inspect native argv; remove PowerShell-only flags |
| Chinese text renders incorrectly | compare file bytes/UTF-8 decode with terminal output |
| works locally but asks approval | simplify to one stable command segment |
| access denied or network blocked | request narrow escalation; do not alter quoting blindly |
| search exits 1 with no output | treat as no matches, not a shell error |
| long job appears silent | poll the existing process; do not start a duplicate |
