-- Saves 1s after leaving insert mode / changing text, and immediately on buffer switch,
-- focus loss and quit. :ASToggle turns it off/on for the session.
return {
  {
    "okuuva/auto-save.nvim",
    version = "^1.0.0",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      -- only real files: skip special buffers (file tree, test panel, pickers) and commit messages
      condition = function(buf)
        return vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "gitcommit"
      end,
    },
  },
}
