-- Vymrland Hyprland entry point.
--
-- Omarchy's default bindings stay ENABLED. Vymrland layers on top and unbinds
-- only the specific keys it repurposes (see hypr/bindings.lua). Do NOT set
-- omarchy_default_bindings = false here.

-- Omarchy's bootstrap keeps path setup out of the user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy defaults first (bindings, looknfeel, input, windows, theme).
require("default.hypr.omarchy")

-- Personal overrides, loaded after Omarchy's defaults so package updates can
-- improve the defaults without rewriting these files.
require("hypr.monitors")
require("hypr.input")
require("hypr.mouse")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Vymrland vim-style navigation (focus/move/resize/workspaces/monitors).
require("hypr.keymaps.global")

-- HyprVim (pinned) + the Ctrl-W window submap + app routing policy.
require("hypr.hyprvim")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
