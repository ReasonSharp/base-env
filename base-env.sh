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

    # Skip if this is an autocomplete attempt
    if [[ -n "$COMP_LINE" || -n "$COMP_POINT" ]]; then
	    return 0
    fi
    
    # If interactive
    if [[ $- =~ i ]]; then
	    local new_cmd=$(echo "$cmd_line" | sed "s|^~/|$BASE/|g;s|^\\$HOME/|$BASE/|g;s|^\\${HOME}/|${BASE}/|g")
	    if [[ "$new_cmd" != "$cmd_line" ]]; then
		    ( HOME="$REAL_HOME" eval "$new_cmd" )
		    return 1
            fi
    fi
    eval "HOME=\"$REAL_HOME\" $new_cmd"
    return 1
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

