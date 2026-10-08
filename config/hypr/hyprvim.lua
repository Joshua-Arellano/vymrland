-- HyprVim setup. install.sh clones uhs-robert/hyprvim into
-- ~/.local/share/hyprland/lua/plugins/hyprvim and pins it to v4.0.1.
--
-- Loaded after Omarchy defaults and Vymrland's global keymaps, so its binds
-- (SUPER+V to enter NORMAL, SUPER+ESC to exit) win.

local home = os.getenv("HOME") or ""
local omarchy_path = os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"

local hyprvim = dofile(home .. "/.local/share/hyprland/lua/plugins/hyprvim/init.lua")
hyprvim.setup({
  keys = {
    leader = "SUPER",
    activate = "V",
    exit = "ESCAPE",
  },
  applications = {
    terminal = "ghostty",
    lock = "omarchy-system-lock",
    editor = "nvim",
  },
  -- Pinned: install.sh checks out v4.0.1; keep the self-updater quiet.
  updates = { channel = "off" },
  -- HyprVim's built-in list only knows `ghostty`, but Ghostty's Wayland
  -- app-id is `com.mitchellh.ghostty`. Providing this key replaces the
  -- default table, so list the full set.
  terminal_classes = {
    "kitty",
    "alacritty",
    "foot",
    "footclient",
    "wezterm",
    "org.wezfurlong.wezterm",
    "ghostty",
    "com.mitchellh.ghostty",
    "org.omarchy.terminal",
    "org.omarchy.opencode",
  },
  which_key = {
    enabled = true,
    frontend = "quickshell",
    quickshell_ipc = "qs ipc -n -p " .. omarchy_path .. "/shell",
  },
  prompt = { frontend = "quickshell" },
  -- NORMAL-mode overrides. CTRL+W opens Vymrland's window submap, defined in
  -- hypr/keymaps/submaps/ctrlw.lua (required below).
  keymaps = {
    NORMAL = {
      { "CTRL + W", function() require("hyprvim.lib.submap").enter("WINDOW") end },
    },
  },
})

-- Vymrland's Ctrl-W window submap.
require("hypr.keymaps.submaps.ctrlw")

-- Routing policy: HyprVim owns keys only for GUI apps. When focus lands on a
-- terminal, Tridactyl/Vimium browser, or Neovim GUI, the app's own vim layer
-- owns the keys and HyprVim leaves its submap.
require("hypr.hyprvim_routing")
