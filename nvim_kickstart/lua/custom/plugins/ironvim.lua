return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    iron.setup({
      config = {
        -- Whether a repl should be discarded or not
        scratch_repl = false,

        -- Highlights the last sent block with bold
        highlight_last = "IronLastSent",

        -- Your repl definitions come here
        repl_definition = {
          sh = {
            -- Can be a table or a function that
            -- returns a table (see below)
            command = { "zsh" },
          },
          python = require("iron.fts.python").ipython,
          -- python = {
          --   -- require("iron.fts.python").ipython
          --   command = function(meta)
          --     local filename = vim.api.nvim_buf_get_name(meta.current_bufnr)
          --     return { "ipython", "--no-autoindent" }
          --   end,
          -- }
        },
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = view.split.vertical.botright(60),
      },
      -- Iron doesn't set keymaps by default anymore.
      -- You can set them here or manually add keymaps to the functions in iron.core
      keymaps = {
        send_motion = "<leader>cc",
        visual_send = "<leader>cc",
        send_file = "<leader>cf",
        send_line = "<leader>cl",
        send_until_cursor = "<leader>cu",
        send_mark = "<leader>cm",
        mark_motion = "<leader>cc",
        mark_visual = "<leader>cc",
        remove_mark = "<leader>cd",
        cr = "<leader>c<cr>",
        interrupt = "<leader>c<leader>",
        exit = "<leader>cq",
        clear = "<leader>cl",
      },
      -- If the highlight is on, you can change how it looks
      -- For the available options, check nvim_set_hl
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    })
  end,
}
