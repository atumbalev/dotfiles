return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    keys = {
      { "<leader>cP", "<cmd>RenderMarkdown preview<cr>", desc = "Markdown Preview (split)", ft = "markdown" },
    },
  },
  -- Don't run markdownlint on markdown files (too noisy for reading)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  -- Hide remaining diagnostics (e.g. marksman) in markdown buffers
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          vim.diagnostic.enable(false, { bufnr = ev.buf })
        end,
      })
    end,
  },
}
