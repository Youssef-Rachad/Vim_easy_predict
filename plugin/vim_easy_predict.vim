" Vim Autocomplete File
" Name:       vim_easy_predict.vim
" Based On: vim-simple-complete by github.com/MaxBoisVert
"---Make sure the plugin is loaded
if exists("g:loaded_vim_easy_predict")
    finish
endif
let g:loaded_vim_easy_predict = 1

"---Completion commands
"Prefix for completion
let s:vep_ctrl_x = get(s:, 'vep_ctrl_x', "\<C-X>")
"Suffix for completion
let g:vep_completion_command = get(g:, 'vep_completion_command', "\<C-N>")
let g:vep_omni_completion_command = get(g:, 'vep_omni_completion_command', "\<C-O>")
let g:vep_reverse_completion_command = get(g:, 'vep_reverse_completion_command', "\<C-P>")
let g:vep_tab_complete = get(g:, 'vep_tab_complete', 1)
let g:vep_type_complete = get(g:, 'vep_type_complete', 1)
"Set initial state of completion
let s:vep_state = get(s:, "vep_state", "vep_comp")
"---Minimum word length & Get the keywords
let g:vep_type_complete_length = get(g:, 'vep_type_complete_length', 2)
let g:vep_pattern = get(g:, 'vep_pattern', '\k')

fun! s:TabCompletePlugin()
    inoremap <expr> <Tab> <SID>TabComplete(0)
    inoremap <expr> <S-Tab> <SID>TabComplete(1)
    inoremap <expr> <C-S> <SID>Toggloo()
    "Switch between omni-complete and context-complete
    fun! s:Toggloo()
        if s:vep_state == "vep_omni" && pumvisible()
            let s:vep_state = "vep_comp"
            return s:vep_ctrl_x.g:vep_completion_command
        elseif s:vep_state == "vep_comp" && pumvisible()
            let s:vep_state = "vep_omni"
            return s:vep_ctrl_x.g:vep_omni_completion_command
        else
            return "\<C-S>"
        endif
    endfun
    "Cycle through results
    fun! s:TabComplete(reverse)
        "if curchar matches regex of either
        if s:CurrentChar() =~ g:vep_pattern || pumvisible()
            if a:reverse
                return (g:vep_reverse_completion_command)
            else
                let s:vep_state = "vep_comp"
                return (g:vep_completion_command)
            endif
        else
            return "\<Tab>"
        endif
    endfun

endfun

fun! s:CurrentChar()
    return matchstr(getline('.'), '.\%' . col('.') . 'c')
endfun

fun! s:TypeCompletePlugin()
    set completeopt+=menu,menuone,preview,noselect
    set completeopt+=popup
    set pumheight=7
    let s:vep_typed_length = 0
    imap <silent> <expr> <plug>(TypeCompleteCommand) <sid>TypeCompleteCommand()

    augroup TypeCompletePlugin
        autocmd!
        autocmd InsertCharPre * noautocmd call s:TypeComplete()
        autocmd InsertEnter * let s:vep_typed_length = 0
    augroup END

    fun! s:TypeCompleteCommand()
        let s:vep_state = "vep_comp"
        return s:vep_ctrl_x.g:vep_completion_command
    endfun

    fun! s:TypeComplete()
        if v:char !~ g:vep_pattern
            let s:vep_typed_length = 0
            return
        endif

        let s:vep_typed_length += 1

        if !g:vep_type_complete || pumvisible()
            return
        endif

        if s:vep_typed_length == g:vep_type_complete_length
            call feedkeys("\<plug>(TypeCompleteCommand)", 'i')
        endif
    endfun
endfun
"calling the correct completion
if g:vep_type_complete | call s:TypeCompletePlugin() | endif
if g:vep_tab_complete  | call s:TabCompletePlugin()  | endif
