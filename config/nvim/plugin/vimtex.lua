-- VimTeX configuration with Tectonic & Zathura
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'tectonic'
vim.g.vimtex_compiler_progname = 'nvr'

-- Tectonic compiler options
vim.g.vimtex_compiler_tectonic = {
  options = {
    '--synctex',
    '--keep-intermediates',
  },
}

-- Keep quickfix window clean
vim.g.vimtex_quickfix_open_on_warning = 0

-- Auto compile on write for seamless live preview
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('VimtexAutoCompile', { clear = true }),
  pattern = '*.tex',
  callback = function()
    if vim.fn.exists(':VimtexCompileSS') == 2 then
      vim.cmd('silent! VimtexCompileSS')
    end
  end,
})
