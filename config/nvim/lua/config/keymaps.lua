-- Vymrland: revert LazyVim's opinionated keymap deviations.
--
-- Loaded on VeryLazy, after LazyVim's own keymaps, so the deletions below take
-- effect. Leader stays Space (LazyVim default).
--
-- Kept from LazyVim: everything else, including the <C-w> window prefix.

local del = function(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

-- Restore j/k to logical-line motion (LazyVim maps them to gj/gk without count).
del({ "n", "x" }, "j")
del({ "n", "x" }, "k")
del({ "n", "x" }, "<Down>")
del({ "n", "x" }, "<Up>")

-- Hand <C-h/j/k/l> back to zellij: split navigation lives there.
del("n", "<C-h>")
del("n", "<C-j>")
del("n", "<C-k>")
del("n", "<C-l>")

-- Restore plain n/N search motion (LazyVim keeps direction + centers).
del("n", "n")
del("x", "n")
del("o", "n")
del("n", "N")
del("x", "N")
del("o", "N")

-- Restore <Esc> (LazyVim clears hlsearch and stops snippets).
del({ "i", "n", "s" }, "<esc>")

-- Remove LazyVim's insert-mode punctuation undo-break remaps.
del("i", ",")
del("i", ".")
del("i", ";")
