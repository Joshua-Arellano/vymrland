-- Vymrland keybindings: window actions, system/menu, and app launches.
--
-- Omarchy defaults stay enabled. Every key Vymrland repurposes is unbound from
-- its Omarchy default first (hl.unbind) and then rebound below.
--
-- Directional vim motions (focus/move/resize), workspace cycling, monitor focus
-- and window cycling live in hypr/keymaps/global.lua, which loads after this
-- file.

-- ===========================================================================
-- Unbind Omarchy defaults that Vymrland repurposes
-- ===========================================================================
hl.unbind("SUPER + W")             -- was: Close window          -> now: next window
hl.unbind("SUPER + L")             -- was: Toggle workspace layout -> now: focus right
hl.unbind("SUPER + S")             -- was: Toggle scratchpad     -> now: split
hl.unbind("SUPER + F")             -- was: Full screen           -> now: float
hl.unbind("SUPER + TAB")           -- was: Next workspace        -> now: last workspace
hl.unbind("SUPER + ESCAPE")        -- was: System menu           -> now: HyprVim exit
hl.unbind("SUPER + SHIFT + F")     -- was: File manager          -> now: fullscreen
hl.unbind("SUPER + SHIFT + B")     -- was: Browser               -> now: previous window
hl.unbind("SUPER + SHIFT + P")     -- was: Google Photos         -> now: pseudo
hl.unbind("SUPER + SHIFT + G")     -- was: Signal                -> now: group
hl.unbind("SUPER + ALT + S")       -- was: Move to scratchpad    -> now: scratchpad toggle
hl.unbind("SUPER + CTRL + H")      -- was: Hardware menu         -> now: resize left
hl.unbind("SUPER + CTRL + K")      -- was: Herdr keybindings     -> now: resize up
hl.unbind("SUPER + CTRL + L")      -- was: Lock system           -> now: resize right
for i = 1, 9 do
  hl.unbind("SUPER + CTRL + code:" .. tostring(i + 9)) -- was: Bar panel i -> now: focus monitor i
end

-- ===========================================================================
-- Window actions
-- ===========================================================================
o.bind("SUPER + Q",         "Close window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Quit Hyprland", hl.dsp.exit())
o.bind("SUPER + S",         "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + F",         "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SHIFT + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ action = "toggle" }))
o.bind("SUPER + SHIFT + P", "Toggle pseudo", hl.dsp.window.pseudo())
o.bind("SUPER + SHIFT + G", "Toggle window grouping", hl.dsp.group.toggle())
o.bind("SUPER + ALT + L",   "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Scratchpad (moved off SUPER+S / SUPER+ALT+S).
o.bind("SUPER + ALT + S",         "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + ALT + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- ===========================================================================
-- System & menu (rebinds + relocated Omarchy bindings)
-- ===========================================================================
o.bind("SUPER + SHIFT + ESCAPE",   "System menu", "omarchy-menu toggle system")
o.bind("SUPER + CTRL + ALT + L",   "Lock system", "omarchy-system-lock")
o.bind("SUPER + CTRL + ALT + H",   "Hardware menu", "omarchy-menu toggle hardware")
o.bind("SUPER + SHIFT + CTRL + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")

-- ===========================================================================
-- Application launches
-- ===========================================================================
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + M", "Music", { tui = "termusic", focus = true })
