# Minimal zsh theme

# Options
num_dirs=2  # Use 0 for full path

# decoration pieces
local return_status="%(?:%F{black}:%F{red})%f"
background_jobs="%(1j:%F{green}:%F{black})%f"
truncated_path="%F{white}%$num_dirs~%f"
decoration="%F{blue}${return_status}"


# git things
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{black}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{magenta}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{black}"


# magic enter
[ "${+LENA_MAGICENTER}" -eq 0 ] && LENAL_MAGICENTER=(lena_me_dirs lena_me_ls lena_me_git)

# Magic enter functions
function lena_me_dirs {
    local _w="\e[0m"
    local _g="\e[38;5;244m"

    if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
        local stack="$(dirs)"
        echo "$_g${stack//\//$_w/$_g}$_w"
    fi
}

function lena_me_ls {
    if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
        COLUMNS=$COLUMNS CLICOLOR_FORCE=1 ls -C -G -F
    else
        ls -C -F --color="always" -w $COLUMNS
    fi
}

function lena_me_git {
    git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
function _lena_wrap {
    local -a arr
    arr=()
    local cmd_out=""
    local cmd
    for cmd in ${(P)1}; do
        cmd_out="$(eval "$cmd")"
        if [ -n "$cmd_out" ]; then
            arr+="$cmd_out"
        fi
    done

    printf '%b' "${(j: :)arr}"
}

# expand string as prompt would do
function _lena_iline {
    echo "${(%)1}"
}


# display magic enter
function _lena_me {
    local -a output
    output=()
    local cmd_out=""
    local cmd
    for cmd in $LENA_MAGICENTER; do
        cmd_out="$(eval "$cmd")"
        if [ -n "$cmd_out" ]; then
            output+="$cmd_out"
        fi
    done
    printf '%b' "${(j:\n:)output}" | less -XFR
}


# draw infoline if no command is given
function _lena_buffer-empty {
    if [ -z "$BUFFER" ]; then
        _lena_me
        zle redisplay
    else
        zle accept-line
    fi
}

# properly bind widgets
# see: https://github.com/zsh-users/zsh-syntax-highlighting/blob/1f1e629290773bd6f9673f364303219d6da11129/zsh-syntax-highlighting.zsh#L292-L356
function _lena_bind_widgets() {
    zmodload zsh/zleparameter

    local -a to_bind
    to_bind=(zle-line-init zle-keymap-select buffer-empty)

    typeset -F SECONDS
    local zle_wprefix=s$SECONDS-r$RANDOM

    local cur_widget
    for cur_widget in $to_bind; do
        case "${widgets[$cur_widget]:-""}" in
            user:_lena_*);;
            user:*)
                zle -N $zle_wprefix-$cur_widget ${widgets[$cur_widget]#*:}
                eval "_lena_ww_${(q)zle_wprefix}-${(q)cur_widget}() { _lena_${(q)cur_widget}; zle ${(q)zle_wprefix}-${(q)cur_widget} }"
                zle -N $cur_widget _lena_ww_$zle_wprefix-$cur_widget
                ;;
            *)
                zle -N $cur_widget _lena_$cur_widget
                ;;
        esac
    done
}

# PROMPT
PROMPT='$truncated_path $decoration$background_jobs$(git_prompt_info) '
RPROMPT=''

lena_bind_widgets

bindkey -M main  "^M" buffer-empty
bindkey -M vicmd "^M" buffer-empty
