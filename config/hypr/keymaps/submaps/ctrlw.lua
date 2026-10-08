-- Vymrland Ctrl-W window submap (HyprVim NORMAL mode).
--
-- Entered from HyprVim NORMAL by pressing CTRL+W (bound via HyprVim's `keymaps`
-- option in hypr/hyprvim.lua). ESC / BackSpace return to NORMAL.
--
-- This is a HyprVim submap (Submap.define), not a raw Hyprland submap, so it
-- participates in HyprVim's state tracking and the which-key HUD.

local Submap = require("hyprvim.lib.submap") ---@class HyprVimSubmap

local function dsp(d)
  return function() hl.dispatch(d) end
end

local function resize(x, y)
  return function() hl.dispatch(hl.dsp.window.resize({ x = x, y = y, relative = true })) end
end

-- Equalize: toggle float twice so the layout recomputes an even split.
local function equalize()
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end

Submap.define({
  name = "WINDOW",
  desc = "+window",
  escape = "NORMAL",
  back = "NORMAL",
  catchall = "stay",
  binds = {
    -- Focus
    { "H", dsp(hl.dsp.focus({ direction = "l" })), "Focus left" },
    { "J", dsp(hl.dsp.focus({ direction = "d" })), "Focus down" },
    { "K", dsp(hl.dsp.focus({ direction = "u" })), "Focus up" },
    { "L", dsp(hl.dsp.focus({ direction = "r" })), "Focus right" },

    -- Move
    { "SHIFT + H", dsp(hl.dsp.window.move({ direction = "l" })), "Move left" },
    { "SHIFT + J", dsp(hl.dsp.window.move({ direction = "d" })), "Move down" },
    { "SHIFT + K", dsp(hl.dsp.window.move({ direction = "u" })), "Move up" },
    { "SHIFT + L", dsp(hl.dsp.window.move({ direction = "r" })), "Move right" },

    -- Width / height / equalize
    { "SHIFT + PERIOD", resize(50, 0), "Increase width" },
    { "SHIFT + COMMA", resize(-50, 0), "Decrease width" },
    { "SHIFT + EQUAL", resize(0, 50), "Increase height" },
    { "MINUS", resize(0, -50), "Decrease height" },
    { "EQUAL", equalize, "Equalize" },

    -- Layout
    { "S", dsp(hl.dsp.layout("togglesplit")), "Toggle split" },
    { "V", dsp(hl.dsp.layout("togglesplit")), "Toggle split (vertical)" },
    { "R", dsp(hl.dsp.layout("rotatesplit")), "Rotate split" },

    -- Window lifecycle
    { "C", dsp(hl.dsp.window.close()), "Close window" },
    { "O", dsp(hl.dsp.exec_cmd("vymrland-window-close-others")), "Only this window" },
    { "W", dsp(hl.dsp.window.cycle_next()), "Cycle windows" },
    { "TAB", dsp(hl.dsp.focus({ workspace = "previous" })), "Last workspace" },
  },
}).setup()
