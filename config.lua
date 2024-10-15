-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.builtin.project.patterns = { ">Projects", ".git" } -- defaults include other VCSs, Makefile, package.json
lvim.colorscheme = "gruvbox"
lvim.plugins = {
  { "lunarvim/colorschemes" },
  { "ellisonleao/gruvbox.nvim" },
  { "tpope/vim-fugitive" },
  { "mg979/vim-visual-multi" },
  { "nvim-telescope/telescope-ui-select.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    lazy = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 0
    end,
  },
  { "mxsdev/nvim-dap-vscode-js" },
  {
    "microsoft/vscode-js-debug",
    lazy = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
  },
  { "David-Kunz/gen.nvim" },
  {
    "davidmh/mdx.nvim",
    config = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" }
  },
  -- { "nake89/vim-mdx-js" },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-CR>",
          clear_suggestion = "<C-X>",
          accept_word = "<C-S-CR>",
        },
      })
    end,
  },
  -- {
  --   "Exafunction/codeium.vim",
  --   config = function()
  --     vim.g.codeium_disable_bindings = 1
  --     -- vim.keymap.set('i', '<C-CR>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
  --     -- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end,
  --     --   { expr = true, silent = true })
  --     -- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end,
  --     --   { expr = true, silent = true })
  --     -- vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
  --     vim.keymap.set('n', '<c-s-c>', function() return vim.fn['codeium#Chat']() end, { expr = true, silent = true })
  --   end
  -- }
}

lvim.builtin.telescope.theme = "ivy"

local components = require("lvim.core.lualine.components")

lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_y = {
  components.spaces,
  components.location,
  components.progress,
  components.diagnostics,
  components.encoding,
}

vim.opt.relativenumber = true

vim.opt.scrolloff = 999
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.showmatch = true

-- require("dap-vscode-js").setup({
--   debugger_path = vim.fn.stdpath('data') ..
--   "/lazy/vscode-js-debug",
--   adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' }, -- which adapters to register in nvim-dap
-- })

local dap = require('dap')

dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "9229", --let both ports be the same for now...
  executable = {
    command = "js-debug-adapter",
    -- -- 💀 Make sure to update this path to point to your installation
    args = { "/Users/k/.local/share/lunarvim/site/pack/lazy/opt/vscode-js-debug/out/src/vsDebugServer.js", "${port}" },
    -- args = { vim.fn.stdpath('data') .. "/lazy/vscode-js-debug", "${port}" },
    -- command = "js-debug-adapter",
    -- args = { "${port}" },
  },
}

for _, language in ipairs({ "typescript", "javascript" }) do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require 'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    }
  }
end

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tsserver", "graphql", "volar", "vuels" })

-- local graphql_lsp_opts = {
--   filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript" },
-- }

-- require("lvim.lsp.manager").setup("graphql", graphql_lsp_opts)
require("lvim.lsp.manager").setup("vuels", {})
require("lvim.lsp.manager").setup("mdx", {
  typescript = {
    enabled = true,
  },
  filetypes = { "mdx" },
})

local capabilities = require("lvim.lsp").common_capabilities()

require("lvim.lsp.manager").setup("tsserver", {
  -- disable_commands = false, -- prevent the plugin from creating Vim commands
  debug = false,     -- enable debug logging for commands
  go_to_source_definition = {
    fallback = true, -- fall back to standard LSP definition on failure
  },
  filetypes = { "vue", "typescript", "typescriptreact", 'javascript', 'javascriptreact', 'mdx' },
  server = { -- pass options to lspconfig's setup method
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = capabilities,
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          path = "~/.local/share/lvim/mason/bin/vue-language-server",
          languages = { "vue" },
        },
      }
    },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  },
})

-- local vue_lsp_opts = {
--   filetypes = { "vue", "typescript" },
-- }

-- require("lvim.lsp.manager").setup("volar", vue_lsp_opts)

-- require("lvim.lsp.manager").setup("tsserver", {
--   init_options = {
--     plugins = {
--       {
--         name = '@vue/typescript-plugin',
--         path = "/Users/k/Library/Application Support/fnm/node-versions/v18.20.2/installation/lib",
--         languages = { 'vue' },
--       },
--     },
--   },
--   filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
-- })

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "eslint", filetypes = { "typescript", "typescriptreact", "vue" } }
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "prettier",
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "mdx" },
  },
}

lvim.lsp.buffer_mappings.visual_mode['gB'] = {
  function()
    local line_start = vim.api.nvim_buf_get_mark(0, "<")[0]
    local line_end = vim.api.nvim_buf_get_mark(0, ">")[0]
    local line_addition = line_end - line_start + 1

    vim.api.nvim_command("G log -L " .. line_start .. ",+" .. line_addition .. ":" .. vim.fn.expand "%")
  end,
  "Git logs a group of lines"
}

require("telescope").load_extension("ui-select")

require "gen".setup({
  model = "llama3:instruct",
  -- model = "starcoder2:15b-q4_K_M",
  host = "localhost",     -- The host running the Ollama service.
  port = "11434",         -- The port on which the Ollama service is listening.
  display_mode = "split", -- The display mode. Can be "float" or "split".
  show_prompt = false,    -- Shows the Prompt submitted to Ollama.
  show_model = false,     -- Displays which model you are using at the beginning of your chat session.
  quit_map = "q",         -- set keymap for quit
  no_auto_close = true,   -- Never closes the window automatically.
  init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
  -- Function to initialize Ollama
  command = function(options)
    return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
  end,
  -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
  -- This can also be a command string.
  -- The executed command must return a JSON object with { response, context }
  -- (context property is optional).
  -- list_models = '<omitted lua function>', -- Retrieves a list of model names
  debug = false -- Prints errors and the command which is run.
})

-- require "llm".setup({
--   enable_suggestions_on_files = {
--     -- disable suggestions in all Telescope windows by enabling only in:
--     "*.*",         -- either has file extension
--     "*/zshrc.d/*", -- or in zshrc.d folder
--   },
--   lsp = {
--     bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
--   },
--   -- tokenizer = {
--   --   repository = "bigcode/starcoder",
--   -- },
--   backend = "ollama",
--   model = "starcoder2:15b-q4_K_M",
--   url = "http://localhost:11434/api/generate",
--   -- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
--   request_body = {
--     -- Modelfile options for the model you use
--     options = {
--       temperature = 0.2,
--       top_p = 0.95,
--     }
--   },
--   debounce_ms = 150,
--   tls_skip_verify_insecure = false,
--   tokens_to_clear = { "<EOT>" },
--   fim = {
--     enabled = true,
--     prefix = "<PRE> ",
--     middle = " <MID>",
--     suffix = " <SUF>",
--   },
--   context_window = 4096,
--   tokenizer = {
--     repository = "codellama/CodeLlama-7b-hf",
--   },
--   adaptor = "ollama",
--   query_params = {
--     maxNewTokens = 60,
--     temperature = 0.5,
--     doSample = true,
--     topP = 0.95,
--   },
--   accept_keymap = "<S-Down>",
--   dismiss_keymap = "<S-Up>",
-- })

-- require "llm".setup({
--   backend = "ollama",
--   model = "codellama:7b",
--   accept_keymap = "<S-CR>",
--   dismiss_keymap = "<CR>",
--   url = "http://localhost:11434/api/generate",
--   request_body = {
--     options = {
--       temperature = 0.2,
--       top_p = 0.95,
--     },
--   },
--   lsp = {
--     bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
--   },
--   -- tokens_to_clear = { "<|endoftext|>" },
--   -- context_window = 16384,
--   -- tokenizer = {
--   --   repository = "bigcode/starcoder2-15b",
--   -- },
--   -- fim = {
--   --   enabled = true,
--   --   prefix = "<fim_prefix>",
--   --   middle = "<fim_middle>",
--   --   suffix = "<fim_suffix>",
--   -- },
--   enable_suggestions_on_startup = true,
--   enable_suggestions_on_files = "*",
-- })
