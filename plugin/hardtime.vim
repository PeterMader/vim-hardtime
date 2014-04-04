" hardtime.vim
" Author: Tom Cammann <cammann.tom@gmail.com>
" Site: https://github.com/takac/vim-hardtime
" Version: 0.4

if exists("g:HardTime_loaded")
    finish
endif
let g:HardTime_loaded = 1

" List of keys to block
if !exists("g:list_of_visual_keys")
    let g:list_of_visual_keys = [ "h", "j", "k", "l", "-",
                     \ "+","<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
endif
if !exists("g:list_of_normal_keys")
    let g:list_of_normal_keys = [ "h", "j", "k", "l", "-",
                     \ "+","<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]
endif

" Allow to ignore certain buffer patterns.
if !exists("g:hardtime_ignore_buffer_patterns")
    let g:hardtime_ignore_buffer_patterns = []
endif

" Timeout in seconds between keystrokes
if !exists("g:hardtime_timeout")
    let g:hardtime_timeout = 1000
endif

if !exists("g:hardtime_showmsg")
    let g:hardtime_showmsg = 0
endif

" Start hardtime in every buffer
if exists("g:hardtime_default_on")
    if g:hardtime_default_on
        autocmd! BufEnter * call s:HardTime()
    endif
endif

let s:lasttime = 0
let s:lastkey = ''

fun! s:HardTime()
    let b:hardtime_on = 1
    let ignoreBuffer = s:IsIgnoreBuffer()
    if !ignoreBuffer
      call HardTimeOn()
    endif
endf

fun! HardTimeOff()
    let b:hardtime_on = 0
    for i in g:list_of_normal_keys
        exec "silent! nunmap <buffer> " . i
    endfor
    for i in g:list_of_visual_keys
        exec "silent! vunmap <buffer> " . i
    endfor
    if g:hardtime_showmsg
        echo "Hard time off"
    endif
endf

fun! HardTimeOn()
    let b:hardtime_on = 1
    for i in g:list_of_normal_keys
        exec "nnoremap <buffer> <silent> <expr> " . i . " TryKey('" . i . "') ? \"" . i . "\" : TooSoon()"
    endfor
    for i in g:list_of_visual_keys
        exec "vnoremap <buffer> <silent> <expr> " . i . " TryKey('" . i . "') ? \"" . i . "\" : TooSoon()"
    endfor
    if g:hardtime_showmsg
        echo "Hard time on"
    end
endf

fun! HardTimeToggle()
    if !exists("b:hardtime_on")
        let b:hardtime_on = 0
    endif
    if b:hardtime_on
        call HardTimeOff()
    else
        call HardTimeOn()
    endif
endf


fun! TryKey(key)
    let now = GetNow()
    if a:key != s:lastkey || now > s:lasttime + g:hardtime_timeout/1000
        let s:lasttime = now
        let s:lastkey = a:key
        echo s:lastkey
        return 1
    else
        return 0
    endif
endf

fun! s:IsIgnoreBuffer()
    let name = bufname("%")
    for i in g:hardtime_ignore_buffer_patterns
        if name =~ i
            return 1
        endif
    endfor
    return 0
endf


fun! TooSoon()
    if g:hardtime_showmsg
        echomsg "Hard time is enabled"
    endif
    return ""
endf

fun! GetNow()
    return reltimestr(reltime())
endf

command! HardTimeOn call HardTimeOn()
command! HardTimeOff call HardTimeOff()
command! HardTimeToggle call HardTimeToggle()
