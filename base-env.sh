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
if [ -z "$preserve_path" ]; then
 cd "$HOME" 2>/dev/null || cd "$REAL_HOME" # fallback if $BASE dir doesn't exist yet
fi

cd() {
	if [ $# -eq 0 ]; then
		command cd "$BASE"
	else
		command cd "$@"
	fi
}

# Function to process Enter key press
process_enter() {
 local cmd_line="$READLINE_LINE"
 if [[ -z "$cmd_line" || "$cmd_line" =~ ^\ *# ]]; then
  READLINE_LINE=""
  echo -e "${PS1@P}$cmd_line"
  return
 fi
 # DEBUG: echo "!!! ENTER !!! -- $cmd_line" >&2  # Debug to stderr
 # Check for incomplete quotes -- this doesn't work for all quotes and in all cases, need parser
 local quote_count=$(echo "$cmd_line" | grep -o '"' | wc -l)
 if [[ $((quote_count % 2)) -ne 0 ]]; then
  # DEBUG: echo "-- mismatched quotes --" >&2
  READLINE_LINE="${cmd_line}"$'\n'
  READLINE_POINT=${#READLINE_LINE}
  return # $PS1 should be replaced with '> ' to imitate bash behavior, then reverted back when all quotes are closed and command is ready to execute
         # or maybe replaced with '' and '> ' should be echoed. For now I leave it as is.
 fi
 # replace any and all instances of ~, $HOME and ${HOME} with ${BASE}, $BASE and ${BASE} respectively - doesn't work sometimes, likely because ^ is start of string, not start of word
 local new_cmd=$(echo "$cmd_line" | sed "s|^~/|\${BASE}/|g;s|^\\$HOME/|\$BASE/|g;s|^\\${HOME}/|\${BASE}/|g")
 # DEBUG: echo "new_cmd='$new_cmd'" >&2 # sed doesn't appear to have had any effect
 # Run command, capture output, let original line stay
 READLINE_LINE=""
 echo -e "${PS1@P}$cmd_line"   # recreate original prompt line
 ( exit $be_retval )           # produce the previous exit status
 HOME="$REAL_HOME" eval "$new_cmd"
 export be_retval=$?           # remember command's return value
 history -s "$cmd_line"        # and add it back to history without our modifications, because that's what we actually typed
 READLINE_POINT=0
}

if [[ $- =~ i ]]; then
 echo "Things that don't work yet:"
 echo ': ~, $HOME and ${HOME} don''t get replaced properly yet'
 echo ': on multiline commands, the ''> '' is not printed on subsequent lines'
 echo ': still on multiline commands, not all quoting is parsed correctly, resulting in possible bad commands'
 echo ': prompt will always print ~'
 bind -x '"\C-m": process_enter'  # Bind Enter (Ctrl+M) to function
 export be_retval=0               # produce initial exit status
fi
