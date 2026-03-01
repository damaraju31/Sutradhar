Stop all active team sessions.

## Step 1 — Check tmux

If not inside tmux (`[ -z "$TMUX" ]`): tell the user "No tmux session found. If teams are running in manual terminal tabs, close them individually." and stop.

## Step 2 — List windows

Run `tmux list-windows -F "#{window_index}: #{window_name}"` and display the results.

## Step 3 — Confirm

Ask the user: "Stop all team windows? (control window stays)"

If the user says no: stop.

## Step 4 — Sync reminder

Remind the user to run `/project-sync` first if teams have pending work (check for any `STATE_UPDATE.md` files that contain actual updates, not just the placeholder "_No pending updates._").

## Step 5 — Stop

Kill all windows except window 0 (the control window):
```
tmux list-windows -F "#{window_index}" | grep -v "^0$" | while read idx; do tmux kill-window -t "$idx"; done
```

Log the stop event to `docs/teams/ACTIVITY.log`:
```
[TIMESTAMP] SESSION_END windows_stopped=N
```

Tell the user how many team windows were stopped.
