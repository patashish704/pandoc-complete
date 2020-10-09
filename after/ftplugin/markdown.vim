augroup pandoc_complete
    autocmd!
    autocmd BufWritePost,BufReadPost *.md call PandocComplete#PopulatePandoc()
augroup END

call PandocComplete#PopulatePandoc()
setlocal omnifunc=PandocComplete#CompletePandoc
" Disable Coc Autocompletion when when this plugin is used
" CocDisable
