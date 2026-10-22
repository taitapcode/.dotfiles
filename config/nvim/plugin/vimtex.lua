-- VimTeX configuration with Tectonic & Zathura
-- <Space>ll  start / stop continuous compile
-- <Space>lv  view PDF in zathura (SyncTeX forward search)
-- <Space>lq  close zathura
-- <Space>lc  clean aux files
-- <Space>le  errors in quickfix
-- <Space>lo  compiler status
-- :VimtexInfo for full state, :h vimtex-mappings for everything else
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

-- Highlighting is Treesitter's job (config/autocmds.lua starts the latex
-- parser on every FileType). VimTeX keeps compile/view/text-object duties
-- only; its own syntax+syntax-callback layer is off. vimtex_syntax_enabled=0
-- also stops VimTeX from printing its syntax-file warnings.
vim.g.vimtex_syntax_enabled = 0
vim.g.vimtex_syntax_conceal_disable = 1

-- Root markers so a Sections/*.tex buffer resolves to its main.tex
vim.g.vimtex_root_markers = { '.latexmkrc', '.vimtexroot', 'main.tex', 'texmf.cnf' }

-- Auto compile on write: saving main.tex or any file it inputs triggers a
-- single-shot build. Skipped while a compile is already running — that covers
-- continuous mode (as well as a build still in flight) and avoids the
-- "Compiler is already running" no-op. VimTeX refuses to start a single-shot
-- while an active continuous job exists, so the two never fight.
local function compiler_running()
  local compiler = vim.b.vimtex.compiler
  local ok, running = pcall(function()
    return compiler:is_running()
  end)
  return ok and running or false
end

vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('VimtexAutoCompile', { clear = true }),
  pattern = '*.tex',
  callback = function()
    local vt = vim.b.vimtex
    if vt == nil or vt.compiler == nil then
      return
    end
    if compiler_running() then
      return
    end
    vim.cmd('silent! VimtexCompileSS')
  end,
})
