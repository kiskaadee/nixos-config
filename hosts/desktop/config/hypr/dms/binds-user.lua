-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.

-- Screen screenshots
hl.bind("SUPER + S", hl.dsp.exec_cmd("grimblast --notify copysave area"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast --notify copysave active"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copysave output"))
hl.bind("SUPER + SHIFT + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copysave screen"))

-- Screen video recordings
hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh area"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh window"))
hl.bind("SUPER + CTRL + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh output"))
hl.bind("SUPER + SHIFT + CTRL + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh screen"))

-- Rebind clipboard manager toggle since SUPER + V is now used for video recording area
hl.bind("SUPER + C", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
