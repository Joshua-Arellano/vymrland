-- Vymrland vim-style navigation layer.
--
-- These are the motions Omarchy does not provide: hjkl focus, shift+hjkl move,
-- ctrl+hjkl resize, bracket workspace cycling, ctrl+number monitor focus, and
-- next/prev window. Workspace 1-0 / shift+1-0 already come from Omarchy.
--
-- Omarchy defaults for the repurposed keys are unbound in hypr/bindings.lua,
-- which loads before this file.

local function dsp(d)
  return function() hl.dispatch(d) end
end

-- Focus (SUPER + h/j/k/l)
hl.bind("SUPER + H", dsp(hl.dsp.focus({ direction = "l" })), { desc = "Focus left" })
hl.bind("SUPER + J", dsp(hl.dsp.focus({ direction = "d" })), { desc = "Focus down" })
hl.bind("SUPER + K", dsp(hl.dsp.focus({ direction = "u" })), { desc = "Focus up" })
hl.bind("SUPER + L", dsp(hl.dsp.focus({ direction = "r" })), { desc = "Focus right" })

-- Move window (SUPER + SHIFT + h/j/k/l)
hl.bind("SUPER + SHIFT + H", dsp(hl.dsp.window.move({ direction = "l" })), { desc = "Move window left" })
hl.bind("SUPER + SHIFT + J", dsp(hl.dsp.window.move({ direction = "d" })), { desc = "Move window down" })
hl.bind("SUPER + SHIFT + K", dsp(hl.dsp.window.move({ direction = "u" })), { desc = "Move window up" })
hl.bind("SUPER + SHIFT + L", dsp(hl.dsp.window.move({ direction = "r" })), { desc = "Move window right" })

-- Resize (SUPER + CTRL + h/j/k/l, tiered: normal / shift = fast)
local function resize(x, y)
  return function() hl.dispatch(hl.dsp.window.resize({ x = x, y = y, relative = true })) end
end

local STEPS = { normal = 10, fast = 100 }
local resize_dirs = {
  { key = "H", x = -1, y = 0 },
  { key = "J", x = 0, y = 1 },
  { key = "K", x = 0, y = -1 },
  { key = "L", x = 1, y = 0 },
}
for _, d in ipairs(resize_dirs) do
  hl.bind("SUPER + CTRL + " .. d.key, resize(d.x * STEPS.normal, d.y * STEPS.normal), { desc = "Resize " .. d.key, repeating = true })
  hl.bind(
    "SUPER + CTRL + SHIFT + " .. d.key,
    resize(d.x * STEPS.fast, d.y * STEPS.fast),
    { desc = "Resize " .. d.key .. " (fast)", repeating = true }
  )
end

-- Workspace cycling (SUPER + ] / [)
hl.bind("SUPER + BRACKETRIGHT", dsp(hl.dsp.focus({ workspace = "e+1" })), { desc = "Next workspace", repeating = true })
hl.bind("SUPER + BRACKETLEFT", dsp(hl.dsp.focus({ workspace = "e-1" })), { desc = "Previous workspace", repeating = true })

-- Last workspace (SUPER + TAB)
hl.bind("SUPER + TAB", dsp(hl.dsp.focus({ workspace = "previous" })), { desc = "Last workspace" })

-- Monitor focus (SUPER + CTRL + 1..9)
for i = 1, 9 do
  hl.bind("SUPER + CTRL + code:" .. tostring(i + 9), dsp(hl.dsp.focus({ monitor = tostring(i - 1) })), { desc = "Focus monitor " .. i })
end

-- Window cycling (SUPER + W / SUPER + SHIFT + B)
hl.bind("SUPER + W", dsp(hl.dsp.window.cycle_next()), { desc = "Next window" })
hl.bind("SUPER + SHIFT + B", dsp(hl.dsp.window.cycle_next({ next = false })), { desc = "Previous window" })
