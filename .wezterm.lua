-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Frappé (Gogh)'

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 14
config.line_height = 1.2

config.enable_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 100
config.window_decorations = "RESIZE"

config.detect_password_input = true

config.macos_window_background_blur = 10

return config
