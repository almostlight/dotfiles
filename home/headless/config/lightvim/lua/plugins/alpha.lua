return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-mini/mini.icons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    -- require('alpha').setup(require('alpha.themes.theta').config)
    require('alpha').setup(require('alpha.themes.startify').config)
  end,
}
