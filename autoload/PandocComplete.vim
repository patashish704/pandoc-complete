"
" A utility function that returns a List of matched strings from an external
" file
"
fun! s:MatchFile(file, pattern)
    let l:matches = []
    if filereadable(a:file)
        let l:lines = readfile(a:file)
        for l:line in l:lines
            call substitute(
                        \ l:line,
                        \ a:pattern,
                        \ '\=add(l:matches, submatch(0))',
                        \ 'g'
                        \ )
        endfor
    endif
    return l:matches
endfun
"
" Write a function that fills b:mylist with unused image file paths
"
fun! s:FetchImageNames()
    let l:dir = ''
    let l:modifier = ''
    if exists('g:PandocComplete_figdirtype')
        if g:PandocComplete_figdirtype == 1
            if exists('g:PandocComplete_figdirpre')
                let l:dir = g:PandocComplete_figdirpre
            endif
        elseif g:PandocComplete_figdirtype == 2
            if exists('g:PandocComplete_figdirpre')
                let l:dir = g:PandocComplete_figdirpre . expand('%:r')
            endif
        elseif g:PandocComplete_figdirtype == 3
            if exists('g:PandocComplete_figdirpre')
                let l:dir = g:PandocComplete_figdirpre . expand('%:r')
                let l:modifier = ':t:r'
            endif
        endif
    endif
    "
    " Add all image extensions to l:filelist
    "
    let l:filelist = []
    call extend(l:filelist, globpath(l:dir, '*.png', 1, 1))
    call extend(l:filelist, globpath(l:dir, '*.jpg', 1, 1))
    call extend(l:filelist, globpath(l:dir, '*.svg', 1, 1))
    call extend(l:filelist, globpath(l:dir, '*.gif', 1, 1))
    call extend(l:filelist, globpath(l:dir, '*.eps', 1, 1))
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
    let l:bibfiles = []
    call execute(
                \ '%s/\v^bibliography\s*:\s*\zs(\w|-|\/|\.|\\)+/' .
                \ '\=add(l:bibfiles, submatch(0))/gn',
                \ 'silent!'
                \ )
    "
    " Parse entries like this in the yaml header:
    " bibliography:
    "   - ashish.bib
    "   - james.bib
    "
    call execute(
                \ '/\v^\s*bibliography\s*:/;/\v^(---|\s*\w+)/' .
                \ 's/\v^\s+-\s+((\w|-|.|\/|\\)+)/' .
                \ '\=add(l:bibfiles, submatch(1))/gn',
                \ 'silent!'
                \ )
    "
    " Extract bib keys from each file in l:bibfiles
    "
    let l:bibkeys = []
    for l:bibfile in l:bibfiles
        call extend(
                    \ l:bibkeys,
                    \ s:MatchFile(
                        \ l:bibfile,
                        \ '^\s*@\w\+{\zs\w\+'
                        \ )
                    \ )
    endfor
    "
    " Extract title corresponding to each citation key. This title will act as
    " additional info that will appear in the popup menu
    "
    let l:bibtemp = []
    for l:bibfile in l:bibfiles
        call extend(
                    \ l:bibtemp,
                    \ s:MatchFile(
                        \ l:bibfile,
                        \ '^\s*title\s*=\s*\zs.*'
                        \ )
                    \ )
    endfor
    "
    " Clean the l:bibtemp of curly braces and commas and store into l:bibinfos
    "
    let l:bibinfos = []
    for l:item in l:bibtemp
        call add(
                \ l:bibinfos,
                \ substitute(
                    \ l:item,
                    \ '{\|}\|,',
                    \ '',
                    \ 'g'
                \ )
                \ )
    endfor
    "
    " NOTE: List type of yaml array representation of 'bibliography' is
    " not supported, i.e.,
    "
    " bibligraphy: [ashish.bib, james.bib]
    "
    " is not supported
    "
    "
    " Now add to b:mylist
    "
    let i = 0
    while i < len(l:bibkeys)
        let l:key = l:bibkeys[i]
        let l:info = l:bibinfos[i]
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
    let l:reflist = []
    call execute(
                \ '%s/\v#\zs(eq:|fig:|lst:|sec:|tbl:)(\w|-)+/' .
                \ '\=add(l:reflist, submatch(0))/gn',
                \  'silent!'
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
fun! s:PopulatePandoc()
    "
    " This is the main function that populates the omni-completion menu
    "
    " Save the cursor position
    "
    let l:save_cursor = getcurpos()
    "
    let b:mylist = []
    "
    " Populate b:mylist with names (relative path) of image files
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
    " Make a new list where first letter of some words in b:mylist is upper
    " case. This is useful for cases where [@Fig:somefigname] like references
    " are inserted in the markdown file, e.g., at the beginning of a sentence.
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
    " Restore the cursor position
    "
    call setpos('.', l:save_cursor)
endfun

"
" Write a function to be passed to omnifunc, to convert b:mylist to
" completemenu list entries
"
fun! PandocComplete#CompletePandoc(findstart, base)
    "
    if a:findstart
        "
        " Populate the completion menu
        "
        call s:PopulatePandoc()
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
