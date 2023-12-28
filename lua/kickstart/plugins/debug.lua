-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- virtual text for debuggers
    "theHamsta/nvim-dap-virtual-text",

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    "mfussenegger/nvim-dap-python",

  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = "launch",
        name = "Launch file",
        cwd = vim.fn.getcwd(), --python is executed from this directory

        program = "${file}",   -- This configuration will launch the current file if used.
        pythonPath = function()
          -- debugpy supports launching an application with a different interpreter then the one used to
          -- launch debugpy itself.
          -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. "python") == 1 then
            return cwd .. "python"
          elseif vim.fn.executable(cwd .. "python") == 1 then
            return cwd .. "python"
          else
            return "python"
          end
        end,
      },
    }
    dap.adapters.lldb = {
      type = 'executable',
      command = '/opt/homebrew/opt/llvm/bin/lldb-vscode',
      env = {
        LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
      },
      name = "lldb"
    }
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
          print(vim.fn.expand('%:r'))
          -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          return vim.fn.expand('%:r')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = true,
      }
    }

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        "gdb",
        "lldb",
        "node",
        "python",
        "codelldb",
        "cpptools"
      },
      automatic_installation = true,
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F7>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = 'Debug: Toggle repl windows' })
    vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Debug: Run last execution" })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }


    require("nvim-dap-virtual-text").setup({})

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F4>', dapui.toggle, { desc = 'Debug: See last session result.' })
    vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle the DAP UI" })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()

    -- python specific config

    local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
    local dap_python = require("dap-python")
    dap_python.setup(path)
    vim.keymap.set(
      "n",
      "<leader>tc",
      "<cmd>lua require('dap-python').test_class()<CR>",
      { noremap = true, silent = true, desc = "test python class" }
    )
    vim.keymap.set(
      "n",
      "<leader>tm",
      "<cmd>lua require('dap-python').test_method()<CR>",
      { noremap = true, silent = true, desc = "test python function" }
    )
  end,
}
