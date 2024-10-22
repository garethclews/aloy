# zsh theme

# Options
num_dirs=2  # Use 0 for full path

# decoration pieces
local return_status="%(?:%F{237}:%F{red})%f"
background_jobs="%(1j:%F{green}:%F{237})%f"
truncated_path="%F{white}%$num_dirs~%f"
decoration="%F{blue}${return_status}"


[ "${+ALOY_MAGICENTER}" -eq 0 ] && ALOY_MAGICENTER=(aloy_me_dirs aloy_me_ls aloy_me_git)


# Components
function aloy_git {
    local statc="%{\e[0;3${ALOY_OK_COLOR}m%}" # assume clean
    local bname="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"

    if [ -n "$bname" ]; then
        if [ -n "$(git status --porcelain 2> /dev/null)" ]; then
            statc="%{\e[0;3${ALOY_ERR_COLOR}m%}"
        fi
        printf '%b' "$statc$bname%{\e[0m%}"
    fi
}

function aloy_hg {
    local statc="%{\e[0;3${ALOY_OK_COLOR}m%}" # assume clean
    local bname="$(hg branch 2> /dev/null)"
    if [ -n "$bname" ]; then
        if [ -n "$(hg status 2> /dev/null)" ]; then
            statc="%{\e[0;3${ALOY_ERR_COLOR}m%}"
        fi
        printf '%b' "$statc$bname%{\e[0m%}"
    fi
}

function aloy_hg_no_color {
    # Assume branch name is clean
    local statc="%{\e[0;3${ALOY_OK_COLOR}m%}"
    local bname=""
    # Defines path as current directory
    local current_dir=$PWD
    # While current path is not root path
    while [[ $current_dir != '/' ]]
    do
        if [[ -d "${current_dir}/.hg" ]]
        then
            if [[ -f "$current_dir/.hg/branch" ]]
            then
                bname=$(<"$current_dir/.hg/branch")
            else
                bname="default"
            fi
            printf '%b' "$statc$bname%{\e[0m%}"
            return;
        fi
        # Defines path as parent directory and keeps looking for :)
        current_dir="${current_dir:h}"
   done
}

function aloy_uhp {
    local _w="%{\e[0m%}"
    local _g="%{\e[38;5;244m%}"
    local cwd="%~"
    cwd="${(%)cwd}"

    printf '%b' "$_g%n$_w@$_g%m$_w:$_g${cwd//\//$_w/$_g}$_w"
}

function aloy_ssh {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        printf '%b' "$(hostname -s)"
    fi
}

function aloy_pyenv {
    if [ -n "$VIRTUAL_ENV" ]; then
        _venv="$(basename $VIRTUAL_ENV)"
        printf '%b' "${_venv%%.*}"
    fi
}

function aloy_err {
    local _w="%{\e[0m%}"
    local _err="%{\e[3${ALOY_ERR_COLOR}m%}"

    if [ "${ALOY_LAST_ERR:-0}" != "0" ]; then
        printf '%b' "$_err$ALOY_LAST_ERR$_w"
    fi
}

function aloy_jobs {
    local _w="%{\e[0m%}"
    local _g="%{\e[38;5;244m%}"

    local job_n="$(jobs | sed -n '$=')"
    if [ "$job_n" -gt 0 ]; then
        printf '%b' "$_g$job_n$_w&"
    fi
}

function aloy_files {
    local _w="%{\e[0m%}"
    local _g="%{\e[38;5;244m%}"

    local a_files="$(ls -1A | sed -n '$=')"
    local v_files="$(ls -1 | sed -n '$=')"
    local h_files="$((a_files - v_files))"

    local output="${_w}[$_g${v_files:-0}"
    if [ "${h_files:-0}" -gt 0 ]; then
        output="$output $_w($_g$h_files$_w)"
    fi
    output="$output${_w}]"

    printf '%b' "$output"
}

# Magic enter functions
function aloy_me_dirs {
    local _w="\e[0m"
    local _g="\e[38;5;244m"

    if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
        local stack="$(dirs)"
        echo "$_g${stack//\//$_w/$_g}$_w"
    fi
}

function aloy_me_ls {
    if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
        COLUMNS=$COLUMNS CLICOLOR_FORCE=1 ls -C -G -F
    else
        ls -C -F --color="always" -w $COLUMNS
    fi
}

function aloy_me_git {
    git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
function _aloy_wrap {
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
function _aloy_iline {
    echo "${(%)1}"
}

# display magic enter
function _aloy_me {
    local -a output
    output=()
    local cmd_out=""
    local cmd
    for cmd in $ALOY_MAGICENTER; do
        cmd_out="$(eval "$cmd")"
        if [ -n "$cmd_out" ]; then
            output+="$cmd_out"
        fi
    done
    printf '%b' "${(j:\n:)output}" | less -XFR
}

# capture exit status and reset prompt
function _aloy_zle-line-init {
    ALOY_LAST_ERR="$?" # I need to capture this ASAP
    zle reset-prompt
}

# redraw prompt on keymap select
function _aloy_zle-keymap-select {
    zle reset-prompt
}

# draw infoline if no command is given
function _aloy_buffer-empty {
    if [ -z "$BUFFER" ]; then
        _aloy_iline "$(_aloy_wrap ALOY_INFOLN)"
        _aloy_me
        zle redisplay
    else
        zle accept-line
    fi
}

# bind widgets
function _aloy_bind_widgets() {
    zmodload zsh/zleparameter

    local -a to_bind
    to_bind=(zle-line-init zle-keymap-select buffer-empty)

    typeset -F SECONDS
    local zle_wprefix=s$SECONDS-r$RANDOM

    local cur_widget
    for cur_widget in $to_bind; do
        case "${widgets[$cur_widget]:-""}" in
            user:_aloy_*);;
            user:*)
                zle -N $zle_wprefix-$cur_widget ${widgets[$cur_widget]#*:}
                eval "_aloy_ww_${(q)zle_wprefix}-${(q)cur_widget}() { _aloy_${(q)cur_widget}; zle ${(q)zle_wprefix}-${(q)cur_widget} }"
                zle -N $cur_widget _aloy_ww_$zle_wprefix-$cur_widget
                ;;
            *)
                zle -N $cur_widget _aloy_$cur_widget
                ;;
        esac
    done
}

function git_prompt_info() {
    local bname="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"

    if [ -n "$bname" ]; then
        [[ -n "$(git status --porcelain 2> /dev/null)" ]] && \
          statc="%F{magenta}" || \
          statc=""

        echo " %F{237}$bname $statc%f"
    fi
}


# PROMPT
PROMPT='$truncated_path $decoration$background_jobs$(git_prompt_info) '
RPROMPT=''

setopt prompt_subst

_aloy_bind_widgets

bindkey -M main  "^M" buffer-empty
