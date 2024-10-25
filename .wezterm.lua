-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Frappé (Gogh)'

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 14
config.line_height = 1.2

-- Only set font for the tab bar
config.window_frame = {
    -- Change "JetBrains Mono" to your preferred font
    font = wezterm.font { family = 'JetBrains Mono', weight = 'Medium' },
    font_size = 11.0,
  }

  -- Force tab bar settings
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = true
  config.enable_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.tab_max_width = 999999

  -- Pastel colors array
  local pastel_colors = {
    '#FFB3BA', -- pink
    '#BAFFC9', -- green
    '#BAE1FF', -- blue
    '#FFFFBA', -- yellow
    '#FFB3F7', -- purple
    '#B3FFEC', -- mint
    '#FFC8B3', -- peach
    '#B3F7FF', -- cyan
    '#E0B3FF', -- lavender
    '#FFE4B3'  -- orange
  }

  -- Function to get consistent color for a tab index
  local function get_tab_color(index)
    return pastel_colors[(index % #pastel_colors) + 1]
  end

  -- Function to darken a color for active tab
  local function darken_color(color)
    local r = tonumber(color:sub(2,3), 16)
    local g = tonumber(color:sub(4,5), 16)
    local b = tonumber(color:sub(6,7), 16)

    r = math.floor(r * 0.7)
    g = math.floor(g * 0.7)
    b = math.floor(b * 0.7)

    return string.format("#%02x%02x%02x", r, g, b)
  end

  -- Custom tab formatter
  wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
      local tab_index = tab.tab_index + 1
      local total_tabs = #tabs

      local min_cell_width = 30
      local total_width = max_width + (2 * total_tabs)
      local tab_width = math.max(min_cell_width, math.floor(total_width / total_tabs))

      local base_color = get_tab_color(tab_index)
      local background = base_color
      local text_color = '#000000'
      local arrow = ''

      -- Make active tab distinct
      if tab.is_active then
          background = darken_color(base_color)
          text_color = '#ffffff'
          -- First add the arrow in black, then switch back to white for the rest of the text
          arrow = { { Foreground = { Color = '#000000' } }, { Text = '▶ ' } }
      elseif hover then
          background = base_color:sub(1,7) .. '99'
      end

      local title = tab.active_pane.title
      local max_title_length = tab_width - 8
      if #title > max_title_length then
          title = wezterm.truncate_right(title, max_title_length - 2) .. '..'
      end

      local padding_length = tab_width - #title - (tab.is_active and 4 or 2) - 4
      local padding = string.rep(' ', math.max(0, padding_length))

      -- Format title with index
      local formatted_title = string.format('%d: %s%s', tab_index, title, padding)

      -- Build the final tab format
      local elements = {
          { Background = { Color = background } },
      }

      -- Add black arrow if active
      if tab.is_active then
          table.insert(elements, arrow[1])
          table.insert(elements, arrow[2])
      else
          table.insert(elements, { Text = ' ' })
      end

      -- Add the rest of the text in the appropriate color
      table.insert(elements, { Foreground = { Color = text_color } })
      table.insert(elements, { Text = formatted_title })

      return elements
    end
  )

  -- Override default window padding
  config.window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
  }

  -- Tab bar colors
  config.colors = {
      tab_bar = {
          background = '#1b1b1b',
      },
  }

  -- Set custom tab bar style
  config.native_macos_fullscreen_mode = false
  config.window_decorations = "RESIZE"

config.detect_password_input = true

config.macos_window_background_blur = 10

return config
