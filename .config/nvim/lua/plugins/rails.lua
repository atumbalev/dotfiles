-- Rails, on top of the lang.ruby extra (ruby-lsp, rubocop, erb-formatter/erb-lint,
-- rdbg debugger, neotest-rspec).
-- For model/route/schema awareness in the LSP, add `gem "ruby-lsp-rails", group: :development`
-- to the app's Gemfile; ruby-lsp picks it up automatically.
return {
  -- :A / :R alternate/related file (model <-> test, controller <-> view),
  -- :Emodel, :Econtroller, :Eview ..., `gf` on partials/associations, :Rails generate
  { "tpope/vim-rails", lazy = false },

  -- Auto-insert `end` after def/do/if/class
  { "brianhuster/treesitter-endwise.nvim" },

  -- Run the app's own rubocop (pinned version + rubocop-rails etc. from its Gemfile)
  -- instead of Mason's global one, and keep ruby-lsp from reporting the same offenses twice.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rubocop = { cmd = { "bundle", "exec", "rubocop", "--lsp" }, mason = false },
        ruby_lsp = { init_options = { linters = {} } },
      },
    },
  },

  -- ERB highlighting; treesitter's ruby indent is unreliable, so vim's regex indent handles ruby
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "embedded_template" },
      indent = { disable = { "ruby" } },
    },
  },

  -- Minitest is the Rails default; rspec is already covered by the ruby extra
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "zidhuss/neotest-minitest" },
    opts = { adapters = { ["neotest-minitest"] = {} } },
  },
}
