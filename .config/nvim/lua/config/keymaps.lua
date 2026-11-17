-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Keep the cursor centred when scrolling half pages and jumping between search results.
-- n/N keep LazyVim's behaviour (n always searches forward, even after ?) and add `zz`.
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centred)" })
map("n", "n", "'Nn'[v:searchforward].'zvzz'", { expr = true, desc = "Next search result (centred)" })
map("n", "N", "'nN'[v:searchforward].'zvzz'", { expr = true, desc = "Prev search result (centred)" })

-- x deletes a character without overwriting the clipboard / unnamed register
map("n", "x", '"_x', { desc = "Delete char (no yank)" })

-- Select the whole file (replaces Vim's increment-number; <C-x> still decrements)
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Test aliases under <leader>r (LazyVim's own are under <leader>t). The summary panel is on
-- <leader>rS because <leader>rp is taken by the refactoring extra's "Debug Print Variable".
map("n", "<leader>rt", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>rT", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })
map("n", "<leader>rd", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
map("n", "<leader>ro", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Test output" })
map("n", "<leader>rS", function()
  require("neotest").summary.toggle()
end, { desc = "Test summary panel" })

-- [n: from anywhere inside a function/method, jump to its name (then gr / K / <leader>cr work on it).
-- Walks up the treesitter tree to the nearest function-like node that has a `name` field.
map("n", "[n", function()
  local node = vim.treesitter.get_node()
  while node do
    local kind = node:type()
    local name = node:field("name")[1]
    if name and (kind:find("function") or kind:find("method") or kind:find("constructor")) then
      vim.cmd("normal! m'") -- add to the jump list, so <C-o> goes back
      local row, col = name:start()
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
      return
    end
    node = node:parent()
  end
  vim.notify("Not inside a function", vim.log.levels.INFO)
end, { desc = "Go to enclosing function name" })

-- Jump between diagnostics and show the message in a popup
map("n", "<C-n>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "<C-p>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
