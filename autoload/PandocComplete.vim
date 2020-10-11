"
" Write a function that fills b:mylist with unused png file paths
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
    "
    let l:filelist = globpath(l:dirpre, '*.png', 1, 1)
    "
    for l:file in l:filelist
        if ! search(l:file, 'nw')
            call add(b:mylist, {
                        \ 'icase': 0,
                        \ 'word': fnamemodify(l:file, l:modifier),
                        \ 'menu': '  [ins-Figure]',
                        \ })
        endif
    endfor
endfun

"
" Write a function that fills b:mylist with bibliography items
"
fun! s:FetchBibItems()
    "
    " parse entriles like this in the yaml header
    " bibliography: mycitations.bib
    "
    let l:bibfile = system(
                \ 'grep -oPs "^bibliography:\s*\K[\w-/.]+" ' . expand('%')
                \ )
    let l:bibkey = systemlist(
                \ 'grep -oPs "^@\w+\{\K[\w]+" ' . l:bibfile
                \ )
    "
    " Add additional info for the citation keys. The title of each bib entry is
    " stored in a list l:bibinfo
    "
    let l:bibinfo = systemlist(
                \ 'sed -nE "/^\s*title\s*=/ s/(\{|\}|,|(^\s*title\s*=\s*))//gp" '
                \ . l:bibfile
                \ )
    "
    " Parse entries like this in the yaml header:
    " bibliography:
    "   - ashish.bib
    "   - james.bib
    "
    " NOTE: List type of yaml array representation of 'bibliography' is
    " not supported, i.e.,
    "
    " bibligraphy: [ashish.bib, james.bib]
    "
    " is not supported
    "
    let l:bibfiles = systemlist(
                \ 'sed -nE "/^bibliography\s*:/, /^[[:alnum:]-]+/ s/^\s+-\s*//gp" '
                \ . expand('%')
                \ )
    for l:bibfileitem in l:bibfiles
        call extend(l:bibkey,
                    \ systemlist(
                    \ 'grep -oPs "^@\w+\{\K[\w]+" ' . l:bibfileitem
                    \ ))
        call extend(l:bibinfo,
                    \ systemlist(
                    \ 'sed -nE "/^\s*title\s*=/ s/(\{|\}|,|(^\s*title\s*=\s*))//gp" '
                    \ . l:bibfileitem
                    \ ))
    endfor
    "
    " Now add to b:mylist
    "
    let i = 0
    while i < len(l:bibkey)
        let l:key = l:bibkey[i]
        let l:info = l:bibinfo[i]
        call add(b:mylist, {
                    \ 'icase': 1,
                    \ 'word': l:key,
                    \ 'menu': '  [Citation]',
                    \ 'info': l:info,
                    \ })
        let i += 1
    endwhile
endfun

"
" Populate b:mylist with labels such as tbl:, eq:, fig: and tbl:
"
fun! s:FetchRefLabels()
    "
    " Now let's add the label refs for figures, equation, tables etc. in the
    " current buffer
    "
    let l:reflist = systemlist(
                \ 'grep -oPs "(?<=#)(eq|fig|tbl|lst|sec):[\w-]+" ' . expand('%')
                \ )
    "
    " Lets add the list items to b:mylist
    "
    for l:item in l:reflist
        if l:item[0:3] ==# 'fig:'
            let l:menu = '  [Figure]'
        elseif l:item[0:2] ==# 'eq:'
            let l:menu = '  [Equation]'
        elseif l:item[0:3] ==# 'tbl:'
            let l:menu = '  [Table]'
        elseif l:item[0:3] ==# 'lst:'
            let l:menu = '  [Listing]'
        elseif l:item[0:3] ==# 'sec:'
            let l:menu = '  [Section]'
        else
            let l:menu = '  [Unknown]'
        endif
        call add(b:mylist, {
                    \ 'icase': 1,
                    \ 'word': l:item,
                    \ 'menu': l:menu,
                    \ })
    endfor
endfun

"
" Putting it all together
"
fun! PandocComplete#PopulatePandoc()
    "
    " This is the main function that populates the omni-completion menu
    "
    let b:mylist = []
    "
    " Populate b:mylist with names (relative path) of png files
    "
    call s:FetchImageNames()
    "
    " Add to b:mylist bibliography entries
    "
    call s:FetchBibItems()
    "
    " Add to b:mylist ref labels for figures, tables, equations etc.
    "
    call s:FetchRefLabels()
    "
    " Make a new list where first letter of each word in b:mylist is upper case
    " This is useful for cases where [@Fig:somefigname] like references are
    " inserted in the markdown file, e.g., at the beginning of a sentence.
    "
    let b:mycaplist = deepcopy(b:mylist)
    for l:item in b:mycaplist
        "
        " l:item is a reference (not copy) to each dictionary in b:mycaplist
        "
        let l:word = l:item['word']
        let l:menu = l:item['menu']
        if l:menu ==# '  [Citation]' || l:menu ==# '  [ins-Figure]'
            continue
        endif
        let l:item['word'] = toupper(l:word[0]) . l:word[1:]
    endfor
    "
endfun

"
" Write a function to be passed to omnifunc, to convert b:mylist to
" completemenu list entries
"
fun! PandocComplete#CompletePandoc(findstart, base)
    "
    if a:findstart
        "
        " locate the start of the word
        "
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
        "
        " find entries matching with a:base
        "
        let l:finallist = b:mylist
        if match(a:base[0], '\u') != -1
            let l:finallist = b:mycaplist
        endif
        let res = []
        for m in l:finallist
            if m['word'] =~ '^' . a:base
                call add(res, m)
            endif
        endfor
        return res
    endif
endfun
