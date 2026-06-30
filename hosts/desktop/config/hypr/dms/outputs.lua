-- Per-output monitor rules — embedded sibling of the legacy outputs.conf fragment.

hl.monitor({
  output = "DP-1",
  mode = "2560x1440@180.0",
  position = "0x0",
  scale = 1,
  vrr = 0
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60.0",
  position = "2560x790",
  scale = 1,
  vrr = 0
})
