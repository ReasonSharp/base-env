# ~/base-env.sh
# custom environment setup for cleaner workflow
# Copyright (C) 2025 Nikola Novak <novak.nikola@proton.me>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# base directory (run with 'BASE=/newbase base-env.sh' to adjust)
export BASE=${BASE:-/base}

# your real home dir from system (should be portable across Linux distros)
REAL_HOME=$(getent passwd "$USER" | cut -d: -f6)

# set HOME to $BASE as default for interactive shell
export HOME=$BASE
cd "$HOME" 2>/dev/null || cd "$REAL_HOME" # fallback if $BASE dir doesn't exist yet

# custom cd behavior
cd() {
 if [ $# -eq 0 ]; then
  command cd "$BASE"
 else
  command cd "$@"
 fi
}

# adjust HOME before each command
adjust_home() {
    # Get the command about to run (BASH_COMMAND holds it)
    local cmd_line="$BASH_COMMAND"
    local cmd=$(echo "$cmd_line" | awk '{print $1}')
    local ret=0
    
    # If interactive
    if [[ $- =~ i ]]; then
            # Check if the command starts with ~/ and rewrite to $BASE
	    if [[ "$cmd_line" =~ ^(~|\$HOME)\/([^[:space:]]+)(.*) ]]; then
	            local script_name="${BASH_REMATCH[2]}"
		    local args="${BASH_REMATCH[3]}"
		    # Suppress original command
		    cmd_line="$BASE/$script_name$args"
		    ret=1
            fi
    fi
    # Check if it's one of our exceptions
    case "$cmd" in
        ls|mv|cp|cd|rm|mkdir|touch)
            export HOME="${BASE}"
            ;;
        *)
            export HOME="$REAL_HOME"
            ;;
    esac
    if [ $ret -eq 1 ]; then
	    # Rewrite ~/script.sh to $BASE/script.sh and execute
            eval "$cmd_line"
    fi
    return $ret
}

# reset HOME to $BASE after each command
reset_home() {
        export HOME="${BASE}"
}

# apply only in interactive shells
if [[ $- =~ i ]]; then
	shopt -u extdebug # Unset extdebug
	shopt -s extdebug # Then enable it
        trap 'adjust_home' DEBUG
        PROMPT_COMMAND='reset_home'
fi

