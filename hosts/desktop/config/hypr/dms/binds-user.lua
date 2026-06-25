-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.

-- Screen screenshots
hl.bind("SUPER + S", hl.dsp.exec_cmd("grimblast --notify copysave area"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast --notify copysave active"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copysave output"))
hl.bind("SUPER + SHIFT + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copysave screen"))

-- Screen video recordings (SUPER + W series)
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh area"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh window"))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh output"))
hl.bind("SUPER + SHIFT + CTRL + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh screen"))
