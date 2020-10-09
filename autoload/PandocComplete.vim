" Write a function that fills b:mylist with unused png file path
"
fun! s:FetchImageNames()
    let l:dirpre = ''
    let l:modifier = ''
    if exists('g:PandocComplete_figdirtype')
        if g:PandocComplete_figdirtype == 1
            if exists('g:PandocComplete_figdirpre')
                let l:dirpre = g:PandocComplete_figdirpre
            endif
        elseif g:PandocComplete_figdirtype == 2
            if exists('g:PandocComplete_figdirpre')
                let l:dirpre = g:PandocComplete_figdirpre . expand('%:r')
            endif
        elseif g:PandocComplete_figdirtype == 3
            if exists('g:PandocComplete_figdirpre')
                let l:dirpre = g:PandocComplete_figdirpre . expand('%:r')
                let l:modifier = ':t:r'
            endif
        endif
    endif
    " let l:dirpre = '_fig-' . expand('%:r')
    let l:filelist = globpath(l:dirpre, '*.png', 1, 1)
    let b:mylist = []
    for l:file in l:filelist
        if ! search(l:file, 'nw')
            call add(b:mylist, {
                        \ 'icase': 0,
                        \ 'word': fnamemodify(l:file, l:modifier),
                        \ 'menu': '  [ins-Figure]',
                        \ })
        endif
    endfor
    " echo b:mylist
endfun
"
" Populate b:mylist with labels such as tbl:, eq:, fig: and tbl:
"
fun! PandocComplete#PopulatePandoc()
    " parse entriles like this
    " bibliography: mycitations.bib
    let l:bibfile = system(
                \ 'grep -oPs "^bibliography:\s*\K[\w-/.]+" ' . expand('%')
                \ )
    let l:biblist = systemlist(
                \ 'grep -oPs "^@\w+\{\K[\w]+" ' . l:bibfile
                \ )
    " Parse entries like:
    " bibliography:
    "   - ashish.bib
    "   - james.bib
    "
    " NOTE: List type of yaml array representation of 'bibliography' is
    " not supported, i.e.,
    " bibligraphy: [ashish.bib, james.bib]
    "
    let l:bibfiles = systemlist(
                \ 'sed -nE ''/^bibliography:/, /^[[:alnum:]-]+/ p'' '
                \ . expand('%') . ' 2>/dev/null | grep -oPs "\s+-\s*\K[\w-/.]+"'
                \ )
    for l:bibfileitem in l:bibfiles
        call extend(l:biblist,
                    \ systemlist(
                    \ 'grep -oPs "^@\w+\{\K[\w]+" ' . l:bibfileitem
                    \ ))
    endfor
    let l:reflist = systemlist(
                \ 'grep -oPs "(?<=#)(eq|fig|tbl|lst):[\w-]+" ' . expand('%')
                \ )
    let l:mylist = l:biblist + l:reflist
    " let b:mylist = []
    call s:FetchImageNames()
    for l:item in l:mylist
        if l:item[0:3] ==# 'fig:'
            let l:menu = '  [Figure]'
        elseif l:item[0:2] ==# 'eq:'
            let l:menu = '  [Equation]'
        elseif l:item[0:3] ==# 'tbl:'
            let l:menu = '  [Table]'
        elseif l:item[0:3] ==# 'lst:'
            let l:menu = '  [Listing]'
        else
            let l:menu = '  [Citation]'
        endif
        call add(b:mylist, {
                    \ 'icase': 1,
                    \ 'word': l:item,
                    \ 'menu': l:menu,
                    \ })
    endfor
    " echo l:bibfile
    " echo l:bibfiles
    " echo l:biblist
    " echo b:mylist
endfun

" Write a function to be passed to omnifunc, to convert b:mylist to
" completemenu options
"
fun! PandocComplete#CompletePandoc(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && (
                    \    line[start - 1] =~ '\a'
                    \ || line[start - 1] =~ '-'
                    \ || line[start - 1] =~ ':'
                    \ || line[start - 1] =~ '\d')
            let start -= 1
        endwhile
        return start
    else
        " find entries matching with "a:base"
        let res = []
        for m in b:mylist
            if m['word'] =~ '^' . a:base
                call add(res, m)
            endif
        endfor
        return res
    endif
endfun

" augroup pandoc_complete
"     autocmd!
"     autocmd BufWritePost,BufReadPost *.md call PandocComplete#PopulatePandoc()
"     autocmd FileType markdown setlocal omnifunc=PandocComplete#CompletePandoc
"     autocmd FileType markdown CocDisable
" augroup END
