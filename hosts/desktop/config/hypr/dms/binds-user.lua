-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.

-- Screen screenshots (Copy to clipboard only, preventing saving files to directory)
hl.bind("SUPER + S", hl.dsp.exec_cmd("grimblast --notify copy area"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast --notify copy active"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copy output"))
hl.bind("SUPER + SHIFT + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copy screen"))

-- Screen video recordings (SUPER + W series)
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh area"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh output"))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh area audio"))
hl.bind("SUPER + SHIFT + CTRL + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh output audio"))

