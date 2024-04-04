if exists('g:loaded_vimwiki_runner_cpp') || &compatible
  finish
endif
let loaded_vimwiki_runner_cpp = 1

function! s:ExtractClasses(programLines)
    let State = 0
    let currentLine = 0
    let currentChar = 0
    let classPar = 0
    let listClasses = []
    let classBegin =0
    for linee in a:programLines
        for char in linee
            if State == 0
                if char == 'c'
                    let State = 2
                    let classBegin = currentLine
                endif
            elseif State == 2
                if char == 'l'
                    let State = 3
                else
                    let State = 0
                endif
            elseif State == 3
                if char == 'a'
                    let State = 4
                else
                    let State = 0
                endif
            elseif State == 4
                if char == 's'
                    let State = 5
                else
                    let State = 0
                endif
            elseif State == 5
                if char == 's'
                    let State = 6
                else
                    let State = 0
                endif
            elseif State == 6
                if char == ' ' || char == '\t' || char == '\n'
                    let State = 6
                elseif char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z'
                    let State = 7
                else
                    let State = 0
                endif
            elseif State == 7
                if char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z' || char >= '0' && char <= '9' || char == ':' || char =='<' || char == '>' || char == '_'
                    let State = 7
                elseif char == ' ' || char == '\t' || char == '\n'
                    let State = 8
                elseif char == '{'
                    let State = 9
                    let classPar = classPar + 1
                else 
                    let State = 0
                endif
            elseif State == 8
                if char == ' ' || char == '\t' || char == '\n'
                    let State = 8
                elseif char == '{'
                    let State = 9
                    let classPar = classPar + 1
                else 
                    let State = 0 
                endif
            elseif State == 9
                if char == '{'
                    let classPar = classPar + 1
                elseif char == '}'
                    let classPar = classPar - 1
                    if classPar == 0 
                        call add(listClasses,[classBegin,currentLine])
                        let State = 0
                    endif 
                endif
            endif

        endfor
        let currentLine = currentLine + 1
    endfor
    return listClasses
endfunction

function! s:ExtractFlags(programLines)
    let flags =[]
    for linee in a:programLines
        if stridx(linee,"////") >=0
            if stridx(linee,"CFLAGS") >= 0
                echom "Found CFLAGS"
                echom linee[stridx(linee,"CFLAGS") + 1:]
                call add(flags,linee[stridx(linee,"CFLAGS") + 7:])
            endif
            if stridx(linee,"LFLAGS") >=0
                echom "Found LFLAGS"
                echom linee[stridx(linee,"LFLAGS") + 1:]
                call add(flags,linee[stridx(linee,"LFLAGS") + 7:])
            endif
        endif
    endfor
    return flags
endfunction

function! s:ExtractFunctions(programLines)
    let stateMachine=0
    let currentLine= 0
    let currentChar = 0
    let funcPar = 0
    let funbegin=-1
    let listFuncBegin = []
    let listFunc = []
    for linee in a:programLines
        for char in linee
            " Beginning of func return type
            if stateMachine == 0
                if char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z'
                    let stateMachine = 1
                    let funcbegin = currentLine
                    continue
                else
                    continue
                endif
            endif
            " Func return type continuation
            if stateMachine == 1
                if char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z' || char >= '0' && char <= '9' || char == ':' || char =='<' || char == '>'
                    continue
                endif
                if char == ' ' || char == '\t' || char == '\n'
                    let stateMachine = 2
                    continue
                else
                    let stateMachine = 0
                    continue
                endif
            endif
            " Space between function type and func name
            if stateMachine == 2
                if char == ' ' || char == '\t' || char == '\n'
                    continue
                endif
                if char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z'
                    let stateMachine = 3
                    continue
                else
                    let stateMachine = 0
                endif
            endif
            " Function name
            if stateMachine == 3
                if char  >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z' || char >= '0' && char <= '9' || char == ':' || char == '_'
                    continue
                endif
                if char == ' ' || char == '\t' || char == '\n'
                    let stateMachine = 4
                    continue
                endif
                if char == '('
                    let stateMachine = 5
                    continue
                else
                    let stateMachine = 0
                    continue
                endif
            endif
            if stateMachine == 4
                if char == ' ' || char == '\t' || char == '\n'
                    continue
                endif
                if char == '('
                    let stateMachine = 5
                    continue
                else
                    let stateMachine = 0
                    continue
                endif
            endif
            if stateMachine == 5
                if char == ')'
                    let stateMachine = 6
                    continue
                else
                    continue
                endif
            endif 
           if stateMachine == 6
                if char == ' ' || char == '\t' || char == '\n'
                    continue
                endif
                if char == '{'
                    let stateMachine = 7
                    let funcPar = funcPar + 1
                    continue
                else
                    let stateMachine = 0
                    continue
                endif
           endif
            if stateMachine == 7
                if char == '{'
                    let funcPar = funcPar + 1
                    continue
                endif
                if char == '}'
                    let funcPar = funcPar - 1
                    if funcPar == 0
                        let stateMachine = 0
                        call add(listFunc,[funcbegin,currentLine])
                        continue
                    endif
                    continue
                else
                    continue
                endif
            endif
           let currentChar = currentChar + 1
        endfor
        if stateMachine == 1
            let stateMachine = 0
        endif
        let currentLine= currentLine + 1
        let currentChar = 0
    endfor
    return listFunc
endfunction


function! vimwiki_runner#cpp#cpp_handler(lines) abort
    let lines = a:lines
    let language_type = "cpp"
    let includes = []
    let main = []
    for linee in lines
        if stridx(linee,"#include") != -1
            call add(includes,linee)
        else
            call add(main , linee)
        endif
    endfor
    " Extract Classes and Function
    let flags = s:ExtractFlags(main)
    if len(flags) > 1
        echom flags[0]
    endif
    if len(flags) > 2
        echom flags[1]
    endif
    let classLines = s:ExtractClasses(main)
    let tempsrcfile = tempname().".".language_type
    call writefile(includes,tempsrcfile)
    call writefile(["#include <stdio.h>",""],tempsrcfile,"a")
    let currClidx = 0
    let currLine = 0
    let main_no_class = []
    for linee in main
        if currClidx >= len(classLines)
            call add(main_no_class,linee)
        else
            let Cbegin = classLines[currClidx][0]
            let Cend = classLines[currClidx][1]
            if currLine < Cbegin
                call add(main_no_class,linee)
            elseif currLine == Cend
                let currClidx = currClidx + 1
            endif
        endif
        let currLine = currLine + 1
    endfor
    let funcLines =  s:ExtractFunctions(main_no_class)

    for funci in funcLines
        let Fbegin = funci[0]
        let Fend = funci[1]
        let body = main_no_class[Fbegin:Fend]
        call writefile(body,tempsrcfile,"a")
    endfor
    for classi in classLines
        let Cbegin = classi[0]
        let Cend = classi[1]
        let Cbody = main[Cbegin:Cend]
        call writefile(Cbody,tempsrcfile,"a")
    endfor 
    call writefile(["","int main(){"],tempsrcfile,"a")
    let currLine = 0
    let currFnidx = 0
    for linee in main_no_class
        if currFnidx >= len(funcLines)
           call writefile([linee],tempsrcfile,"a")
           continue
        endif
        let Fbegin = funcLines[currFnidx][0]
        let Fend = funcLines[currFnidx][1]
        if currLine < Fbegin 
           call writefile([linee],tempsrcfile,"a")
        endif
        if currLine == Fend
            let currFnidx = currFnidx + 1
        endif
        let currLine = currLine + 1
    endfor
    call writefile(["}"],tempsrcfile,"a")
    if len(flags) > 1
        call asyncrun#run("",{"mode":"term","pos":"bottom"}, "g++ ".flags[0]." ".tempsrcfile." -o ".tempsrcfile.".out ".flags[1]." && ".tempsrcfile.".out")
    else
        call asyncrun#run("",{"mode":"term","pos":"bottom"}, "g++ ".tempsrcfile." -o ".tempsrcfile.".out  && ".tempsrcfile.".out")
    endif 

endfunction


