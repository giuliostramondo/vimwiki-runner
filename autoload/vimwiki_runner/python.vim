if exists('g:loaded_vimwiki_runner_python') || &compatible
  finish
endif
let loaded_vimwiki_runner_python = 1


function! vimwiki_runner#python#python_handler(lines) abort
    echom "called python handler"
    let lines = a:lines
    let language_type = "py"
    let tempsrcfile = tempname().".".language_type
    call writefile(lines,tempsrcfile)
    call asyncrun#run("",{"mode":"term","pos":"bottom"}, "python3 ".tempsrcfile)
endfunction
