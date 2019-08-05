# Minimal zsh theme


# failure
local return_status="%(?:%F{grey}:%F{red})"

# Configuration
num_dirs=2  # Use 0 for full path

truncated_path="%F{white}%$num_dirs~%f"

decoration="%F{blue}${return_status}%F{green}%f"




background_jobs="%(1j.%F{yellow} %f.)"
non_zero_return_value="%(0?..%F{cyan}⏽ %f)"

# Left part of prompt
PROMPT='$truncated_path $decoration '
# Right part of prompt
RPROMPT='$background_jobs  $non_zero_return_value'
# Input in bold
zle_highlight=(default:bold)
