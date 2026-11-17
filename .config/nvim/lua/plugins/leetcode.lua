return {
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "python3",
      -- allow :Leet in an nvim that already has files open (leave with :Leet exit)
      plugins = { non_standalone = true },
      -- shorter import block than the default ~35 lines, with lint suppressions so
      -- ruff/pyright don't flag every `import *` (this block is never submitted)
      injector = {
        ["python3"] = {
          imports = function()
            return {
              "# ruff: noqa: F401, F403, F405",
              "# pyright: reportWildcardImportFromLibrary=false",
              "from typing import *",
              "from collections import *",
              "from heapq import *",
              "from bisect import *",
              "from math import *",
              "from functools import *",
              "from itertools import *",
              "from operator import *",
            }
          end,
        },
      },
      storage = {
        -- keep solutions next to the interview notes
        home = vim.fn.expand("~/Documents/interview-prep/leetcode"),
      },
    },
  },
  -- problem descriptions are rendered from HTML
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "html" } },
  },
}
