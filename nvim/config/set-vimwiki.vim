let g:vimwiki_global_ext = 0
let g:vim_wiki_set_path = expand('<sfile>:p:h')
let g:vimwiki_list = [
        \{
        \   'path': '~/dfdrdodm95.github.io/_wiki',
        \   'ext': 'md',
        \   'diary_rel_path': '.',
        \},
        \{
        \   'path': '~/_wiki',
        \   'ext': 'md',
        \   'diary_rel_path': '.',
        \},
    \]

" If buffer modified, update any 'Last modified: ' in the first 20 lines.
" 'Last modified: ' can have up to 10 characters before (they are retained).
" Restores cursor and window position using save_cursor variable.
function! LastModified()
    if g:md_modify_disabled
        return
    endif

    if (&filetype != "vimwiki")
        return
    endif

    if &modified
        " echo('markdown updated time modified')
        let save_cursor = getpos(".")
        let n = min([10, line("$")])

        exe 'keepjumps 1,' . n . 's#^\(.\{,10}updated\s*: \).*#\1' .
                    \ strftime('%Y-%m-%d %H:%M:%S +0900') . '#e'
        call histdel('search', -1)
        call setpos('.', save_cursor)
    endif
endfun

function! NewTemplate()

    let l:wiki_directory = v:false

    for wiki in g:vimwiki_list
        if expand('%:p:h') . '/' =~ expand(wiki.path)
            let l:wiki_directory = v:true
            break
        endif
    endfor

    if !l:wiki_directory
        return
    endif

    if line("$") > 1
        let b:resource_id = GetResourceId()
        return
    endif

    let l:uuid = substitute(system("uuidgen"), '\n', '', '')
    let b:resource_id = substitute(l:uuid, '^\(..\)', '\1/', '')
    let l:template = []
    call add(l:template, '---')
    call add(l:template, 'layout  : wiki')
    call add(l:template, 'title   : ')
    call add(l:template, 'summary : ')
    call add(l:template, 'date    : ' . strftime('%Y-%m-%d %H:%M:%S +0900'))
    call add(l:template, 'updated : ' . strftime('%Y-%m-%d %H:%M:%S +0900'))
    call add(l:template, 'tag     : ')
    call add(l:template, 'resource: ' . b:resource_id)
    call add(l:template, 'toc     : true')
    call add(l:template, 'public  : true')
    call add(l:template, 'parent  : ')
    call add(l:template, 'latex   : false')
    call add(l:template, '---')
    call add(l:template, '* TOC')
    call add(l:template, '{:toc}')
    call add(l:template, '')
    call add(l:template, '# ')
    call setline(1, l:template)
    execute 'normal! G'
    execute 'normal! $'

    echom 'new wiki page has created'
endfunction

function! BufOpenEvent()
    call NewTemplate()
endfunction

function! GetResourceId()
    for i in range(1, 10)
        let l:line = getline(i)
        if line =~ '^resource: '
            " \zs 오른쪽부터 매칭된다
            return matchstr(l:line, '\v^resource:\s*\zs.*')
        endif
    endfor
    return ''
endfunction

augroup vimwikiauto
    autocmd BufWritePre *wiki/*.md call LastModified()
    autocmd BufRead,BufNewFile *wiki/*.md call NewTemplate()
    " g:md_modify_disabled 를 토글한다.
    autocmd FileType vimwiki nnoremap <silent> s,d :let g:md_modify_disabled = !g:md_modify_disabled<CR>
augroup END

let g:md_modify_disabled = 0

