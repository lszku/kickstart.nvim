return {
  "scalameta/nvim-metals",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
  },
  -- config_org = function(_, opts)
  -- end,
  ft = { "scala", "sbt" },
  config = function(self)
    ---------------  DAP configuration  ---------------
    local dap = require("dap")

    dap.adapters.scala = {
      type = "executable",
      command = "java",
      args = {
        "-jar",
        "/home/Luke/.local/share/nvim/dapinstall/scala-debug-adapter/scala-debug-adapter.jar",
      },
    }

    -- Codelens discussion
    -- https://github.com/scalameta/nvim-metals/discussions/160

    dap.configurations.scala = {
      {
        type = "scala",
        request = "launch",
        name = "Run",
        metals = {
          runType = "run",
          args = {},
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "Test File",
        metals = {
          runType = "testFile",
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "Test Target",
        metals = {
          runType = "testTarget",
        },
      },
      {
        type = "scala",
        request = "attach",
        hostName = "localhost",
        port = 5005,
        -- buildTarget = "root",
        name = "Attach to Playframework",
        metals = {
          runType = "run",
          mainClass = "play.core.server.ProdServerStart",
          args = {},
        },
      },
    }

    ---------------  Metals configuration  ---------------

    local metals_config = require("metals").bare_config()
    local keymap = vim.keymap -- for conciseness

    -- https://scalameta.org/metals/docs/integrations/new-editor/
    -- metals.compilerOptions.isHoverDocumentationEnabled = true

    metals_config.statusBarProvider = "on"
    metals_config.bspStatusBarProvider = "on"
    metals_config.treeViewProvider = true
    metals_config.debuggingProvider = true
    metals_config.decorationProvider = true
    metals_config.inlineDecorationProvider = true

    metals_config.settings = {
      -- serverVersion = "latest.snapshot",
      showImplicitArguments = true,
      showInferredType = true,
      -- javaHome = "~/.sdkman/candidates/java/current",
      showImplicitConversionsAndClasses = true,
      excludedPackages = { "akka.actor.typed.javadsl", "akka.actor.typed.scaladsl" },
      superMethodLensesEnabled = true,
      enableSemanticHighlighting = true,
      -- testUserInterface = "Test Explorer",
    }
    metals_config.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = {
            prefix = "●",
            spacing = 0,
          },
          signs = true,
          underline = true,
        })

    -- local function metals_status_handler(err, status, ctx)
    --   local val = {}
    --   -- trim and remove spinner
    --   local text = status.text:gsub('[⠇⠋⠙⠸⠴⠦]', ''):gsub("^%s*(.-)%s*$", "%1")
    --   if status.hide then
    --     val = { kind = "end" }
    --   elseif status.show then
    --     val = { kind = "begin", title = text }
    --   elseif status.text then
    --     val = { kind = "report", message = text }
    --   else
    --     return
    --   end
    --   local msg = { token = "metals", value = val }
    --   vim.lsp.handlers["$/progress"](err, msg, ctx)
    -- end
    -- metals_config.handlers['metals/status'] = metals_status_handler

    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    metals_config.on_attach = function(_, bufnr)
      require("metals").setup_dap()

      local opts = { noremap = true, silent = false }
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Show signature help"
      keymap.set({ "n", "v" }, "<leader>P", vim.lsp.buf.signature_help, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Codelens refresh"
      keymap.set("n", "<leader>cr", vim.lsp.codelens.refresh, opts)

      opts.desc = "Codelens run"
      keymap.set("n", "<leader>cR", vim.lsp.codelens.run, opts)

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Show worksheet output"
      keymap.set("n", "<leader>dd", "<cmd>lua require('metals').hover_worksheet()<CR>", opts) -- show worksheet output

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

      opts.desc = "Format file"
      keymap.set("n", "<leader>L", vim.lsp.buf.format, opts)

      opts.desc = "Organize imports"
      keymap.set("n", "<C-O>", ":MetalsOrganizeImports<CR>", opts)

      opts.desc = "Metals commands"
      keymap.set("n", "<leader>mc", "<cmd>lua require('metals').commands()<CR>", opts)

      opts.desc = "Dependencies tree"
      keymap.set("n", "<leader>mt", "<cmd>lua require('metals.tvp').toggle_tree_view()<CR>", opts)

      opts.desc = "Add workspace folder"
      keymap.set("n", "<leader>awf", vim.lsp.buf.add_workspace_folder, opts)

      metals_config.tvp = {
        icons = {
          enabled = true,
        },
      }

      -- print("On attach for metals is ready!")
      -- print("Metals server is initialized!" .. vim.inspect(metals_config))
      return metals_config
    end


    -- Autocmd that will actually be in charging of starting the whole thing
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      -- NOTE: You may or may not want java included here. You will need it if you
      -- want basic Java support but it may also conflict if you are using
      -- something like nvim-jdtls which also works on a java filetype autocmd.
      pattern = self.ft,
      callback = function()
        -- attach to actually opened buffer each time new buffer is opened
        require("metals").initialize_or_attach(metals_config)
        -- print("Metals server is initialized!")
      end,
      group = nvim_metals_group,
    })
  end,
}
