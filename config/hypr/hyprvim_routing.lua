-- hyprvim_routing.lua
--
-- Keeps HyprVim from double-handling keys in apps that already speak vim:
--   * terminals (tmux / the shell / any TUI, including nvim inside a terminal)
--   * Tridactyl / Vimium browsers
--   * standalone Neovim GUIs (neovide, nvim-qt)
--
-- HyprVim is a *desktop* vim layer for GUI apps that have no vim keys of their
-- own. When focus lands on one of the apps above, that app's own vim layer owns
-- the keys, so we leave HyprVim's submap (NORMAL/VISUAL/operators/...). This also
-- covers `SUPER + V` being pressed while such an app is focused: the submap
-- event fires and we immediately exit.
--
-- Detection prefers Omarchy's own window tags (default/hypr/apps/terminals.lua
-- and apps/browser.lua) so there is a single definition of "terminal" and
-- "browser"; class names are a fallback for windows that are not tagged yet.

local EDITOR_CLASSES = {
  neovide = true,
  ["nvim-qt"] = true,
  neovim = true,
}

local FALLBACK_CLASSES = {
  -- terminals
  ghostty = true,
  ["com.mitchellh.ghostty"] = true,
  kitty = true,
  alacritty = true,
  foot = true,
  footclient = true,
  wezterm = true,
  ["org.wezfurlong.wezterm"] = true,
  -- firefox-based browsers (Tridactyl / Vimium)
  librewolf = true,
  firefox = true,
  zen = true,
  -- chromium-based browsers
  chromium = true,
  ["google-chrome"] = true,
  ["brave-browser"] = true,
  ["microsoft-edge"] = true,
}

local NATIVE_TAGS = {
  terminal = true,
  ["firefox-based-browser"] = true,
  ["chromium-based-browser"] = true,
}

---Read a field off a Hyprland window userdata without raising on destroyed windows.
---@param win any
---@param field string
---@return any
local function field(win, field)
  local ok, value = pcall(function() return win[field] end)
  if ok then return value end
  return nil
end

---True when the window owns its own vim keys and HyprVim must stand down.
---@param win any
---@return boolean
local function is_vim_native(win)
  if not win then return false end

  local cls = field(win, "class") or ""
  if EDITOR_CLASSES[cls] or FALLBACK_CLASSES[cls] then return true end

  local tags = field(win, "tags") or {}
  for _, tag in ipairs(tags) do
    if NATIVE_TAGS[tostring(tag):gsub("%*$", "")] then return true end
  end

  return false
end

---True while a HyprVim submap (not a hyprland-basics submap) is active.
---@return boolean
local function hyprvim_active()
  local ok, Submap = pcall(require, "hyprvim.lib.submap")
  if not ok or type(Submap) ~= "table" then return false end

  local cur = Submap.current
  if not cur or cur == "" or cur == "reset" then return false end
  return Submap.registry and Submap.registry[cur] ~= nil
end

---Leave HyprVim entirely, falling back to a raw submap reset.
local function leave_hyprvim()
  if not hyprvim_active() then return end

  local ok, vim = pcall(require, "hyprvim.vim")
  if ok and type(vim) == "table" and type(vim.exit) == "function" then
    vim.exit()
    return
  end

  hl.dispatch(hl.dsp.submap("reset"))
end

---@param win any
local function maybe_leave(win)
  if is_vim_native(win) then leave_hyprvim() end
end

-- Focus moved onto a vim-native app: hand the keys back to the app.
hl.on("window.active", function(win) maybe_leave(win) end)

-- A HyprVim submap was entered while a vim-native app is focused (e.g. SUPER+V
-- pressed in a terminal): leave immediately so no key is hijacked.
hl.on("keybinds.submap", function() maybe_leave(hl.get_active_window()) end)
