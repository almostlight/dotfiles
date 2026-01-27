return {
  {
    'lervag/vimtex',
    lazy = false,
    config = function()
      -- Use latexmk for compilation
      vim.g.vimtex_compiler_method = 'latexmk'

      -- Enable inline live preview using VimTeX's 'conceal' + 'pylatexenc'
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        greek = 1,
        math_super_sub = 1,
      }

      vim.g.vimtex_view_method = 'zathura' -- or skim, okular, etc.
    end,
  },
}
