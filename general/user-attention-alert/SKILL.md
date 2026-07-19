---
name: user-attention-alert
description: Alert the user with a local audible Windows notification when a verified gate requires their immediate input, manual UI action, approval, or anomaly decision.
---

# User Attention Alert

Use an **alert** only when progress is blocked on the user's action now. Do not
alert for routine status updates or work the agent can continue alone.

1. Verify the gate: state the exact user action or decision, why it is needed,
   and any risk that makes it user-owned.
   Completion: a concise, actionable request exists and no safer agent action
   can advance the gate.
2. Prepare the environment before the alert. Do not ask the user to wait while
   the agent still starts services, opens a capture window, or checks state.
   Completion: the requested action can begin immediately after the alert.
3. Run the bundled script with a short, non-sensitive Chinese message:

   ```powershell
   & "$PSScriptRoot\scripts\notify_user.ps1" -Message '需要你的操作，请查看 Codex 提示。' -Repeat 3
   ```

   Invoke the script from its resolved skill directory when not running inside
   PowerShell. Use `-DryRun` only to validate installation.
   Completion: the alert process exits successfully or the fallback sound was
   attempted.
4. Send the same concise request in chat and wait for the user's response.
   Completion: record the response before resuming the gated action.

Never include credentials, tokens, personal identifiers, raw logs, or secrets
in the spoken message. Keep the message to the operation, for example:
`需要点击一次原始登录按钮。`
