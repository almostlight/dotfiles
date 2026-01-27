return {
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'tree-sitter-cli' } },
  },

  {
    'jbyuki/nabla.nvim',
    ft = 'tex',
    dependencies = {
      'nvim-neo-tree/neo-tree.nvim',
      'williamboman/mason.nvim',
    },
    lazy = true,

    config = function()
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*.tex',
        callback = function()
          require('nabla').enable_virt {
            autogen = true, -- auto-regenerate ASCII art when exiting insert mode
            silent = true, -- silents error messages
          }
        end,
      })
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'latex' },
        auto_install = true,
        sync_install = false,
      }
    end,
  },
}
