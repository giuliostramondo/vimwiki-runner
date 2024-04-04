if exists("g:loaded_vimwiki_runner")
    finish
endif

let g:loaded_vimwiki_runner = 1


function! s:GetProgramFromRegion()
    " Extract language type and code block
    " language_type contains the language type
    " lines contains an array of the lines in the codeblock
    let cursor_pos = getpos('.')
    call searchpos('`','b')
    normal! w
    let language_type=expand('<cword>')
    normal! j^v
    call searchpos('`','W')
    silent normal! k$"iy
    return [language_type, getreg('i',1,1)]
endfunction

function! s:RunProgram()
    let cursor_pos = getpos('.')
    let lan_type_and_lines = s:GetProgramFromRegion()
    let language_type = lan_type_and_lines[0]
    echom "Language type ".language_type
    let lines = lan_type_and_lines[1]
    " Separate includes from codeblock
    " 
    if language_type == "cpp"
        call vimwiki_runner#cpp#cpp_handler(lines)
    endif  
    if language_type == "python"
        call vimwiki_runner#python#python_handler(lines)
    endif
    if language_type == "bash"
        call vimwiki_runner#bash#bash_handler(lines)
    endif
    call setpos('.',cursor_pos)
endfunction

command! -nargs=0 RunProgram call s:RunProgram()

