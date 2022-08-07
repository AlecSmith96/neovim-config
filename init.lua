vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.ignorecase = true -- Case insensitive
vim.opt.smartcase = true -- Case insensitive unless /C or capital in search
-- Display options for hidden charactrs --
vim.opt.list = true -- show some invisible characters
vim.opt.listchars = {
  space = '⋅',
  tab = '__',
  trail = '•',
  extends = '❯',
  precedes = '❮',
  nbsp = '_',
}
vim.opt.tabstop = 2 -- default spaces for tab
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.shiftwidth = 2 -- size of an indent
vim.opt.shiftround = true -- round indent to multiple of shiftwidth
vim.opt.breakindent = true -- Enable break indent
vim.opt.smartindent = true -- Smart autoindenting on new line
vim.opt.hidden = true -- Do not save when switching buffers
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.cmd([[autocmd FileType go setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4]])

-- Run gofmt + goimport on save
vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').goimport() ]], false)

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

-- boostrap package manager
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  requires = {
	    -- LSP Support
	    {'neovim/nvim-lspconfig'},
	    {'williamboman/mason.nvim'},
	    {'williamboman/mason-lspconfig.nvim'},
      {'ray-x/go.nvim'},
      {'ray-x/guihua.lua'},

	    -- Autocompletion
	    {'hrsh7th/nvim-cmp'},
	    {'hrsh7th/cmp-buffer'},
	    {'hrsh7th/cmp-path'},
	    {'saadparwaiz1/cmp_luasnip'},
	    {'hrsh7th/cmp-nvim-lsp'},
	    {'hrsh7th/cmp-nvim-lua'},

	    -- Snippets
	    {'L3MON4D3/LuaSnip'},
	    {'rafamadriz/friendly-snippets'},
	  },
  config = function()
    local lsp = require('lsp-zero')

    lsp.preset('recommended')
    lsp.setup()

    require('go').setup()
  end
  }

  use {
      'nvim-treesitter/nvim-treesitter',
      requires = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
    config = function()
      -- [[ Configure Treesitter ]]
    -- See `:help nvim-treesitter`
    require('nvim-treesitter.configs').setup {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = { 'lua', 'typescript', 'rust', 'go', 'python' },

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          -- TODO: I'm not sure for this one.
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    }
    end
    }

  use {
 	"rebelot/kanagawa.nvim",
	config = function()
		-- Default options:
		require('kanagawa').setup({
		    undercurl = true,           -- enable undercurls
		    commentStyle = { italic = true },
		    functionStyle = {},
		    keywordStyle = { italic = true},
		    statementStyle = { bold = true },
		    typeStyle = {},
		    variablebuiltinStyle = { italic = true},
		    specialReturn = true,       -- special highlight for the return keyword
		    specialException = true,    -- special highlight for exception handling keywords
		    transparent = false,        -- do not set background color
		    dimInactive = false,        -- dim inactive window `:h hl-NormalNC`
		    globalStatus = false,       -- adjust window separators highlight for laststatus=3
		    terminalColors = true,      -- define vim.g.terminal_color_{0,17}
		    colors = {},
		    overrides = {},
		})

		-- setup must be called before loading
		vim.cmd("colorscheme kanagawa")
  end
  }
  use {
  	'lewis6991/gitsigns.nvim',
	  config = function()
	    require('gitsigns').setup()
  end
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
	    require('lualine').setup()
    end
  }
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }
  }
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)


