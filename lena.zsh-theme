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


# PROMPT
PROMPT='$truncated_path $decoration$background_jobs$(git_prompt_info) '
RPROMPT=''
