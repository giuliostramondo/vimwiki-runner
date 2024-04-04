if exists('g:loaded_vimwiki_runner_bash') || &compatible
  finish
endif
let loaded_vimwiki_runner_bash = 1


function! vimwiki_runner#bash#bash_handler(lines) abort
    echom "called bash handler"
    let lines = a:lines
    let language_type = "sh"
    let tempsrcfile = tempname().".".language_type
    call writefile(lines,tempsrcfile)
    call asyncrun#run("",{"mode":"term","pos":"bottom"}, "bash ".tempsrcfile)
endfunction
