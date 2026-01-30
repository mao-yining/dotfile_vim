vim9script
import autoload "../autoload/popup.vim"

# TODO: complete
# - highlight groups as the first word or a link after ->
# - colortemplete keywords
# - /256/16/8/0 after highlight group or as a first thing on the line
# - reverse/bold/italic/underline as the fourth part of the highlight definition
# - none/omit as a second or third part of highlight definition
# - color names (would require scanning of the buffer)
# - Include: for files
# - Environments: for gui/256/16/8/0

export def HighlightCompletor(findstart: number, base: string): any
    if findstart > 0
        var prefix = getline('.')->strpart(0, col('.') - 1)->matchstr('\k\+$')
        if prefix->empty()
            return -2
        endif
        return col('.') - prefix->len() - 1
    endif

    var items = getcompletion('', 'highlight')
        ->mapnew((_, v) => ({word: v, kind: 'h', dup: 0}))
        ->matchfuzzy(base, {key: "word"})

    return items->empty() ? v:none : items
enddef

export def ColorSupport()
    var commands = []
    commands->extend([
        {text: "Color support"},
        {text: "tgc/256", key: "g", cmd: (_) => {
            if &tgc
                set t_Co=256
                set notgc
                popup_notification("Switching to 256 colors", {})
            else
                set t_Co=256
                set tgc
                popup_notification("Switching to GUI colors", {})
            endif
        }},
        {text: "16/8", key: "t", cmd: (_) => {
            set notgc
            if str2nr(&t_Co) == 16
                set t_Co=8
                popup_notification("Switching to 8 colors", {})
            else
                set t_Co=16
                popup_notification("Switching to 16 colors", {})
            endif
        }},
        {text: "0", key: "T", cmd: (_) => {
            set notgc
            set t_Co=0
            popup_notification("Switching to 0 colors", {})
        }},
    ])
    popup.Commands(commands)
enddef

def Run()
    update
    Colortemplate!
    ColortemplateShow
enddef
