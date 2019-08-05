# Minimal zsh theme

# Options
num_dirs=2  # Use 0 for full path

# decoration pieces
local return_status="%(?:%F{black}:%F{red})%f"
background_jobs="%(1j:%F{grey}:%F{green})%f"
truncated_path="%F{white}%$num_dirs~%f"
decoration="%F{blue}${return_status}"


# git things
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{black}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{magenta}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{green}"


# PROMPT
PROMPT='$truncated_path $decoration$background_jobs$(git_prompt_status) '
RPROMPT=''
