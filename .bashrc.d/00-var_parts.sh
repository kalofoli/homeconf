
var_parts_debug=${var_parts_debug:-no}
function var_parts_log() {
	[ "$var_parts_debug" == "yes" ] && echo "$@" >&2
}

function var_parts_debug_on() {
	var_parts_debug=yes
}

function var_parts_debug_off() {
	var_parts_debug=no
}

function var_parts_array_parse() {
	# Parse a string into an array name with optional separator
	# Example:
	#   $ var_parts_array_parse parts "A part_Bee part_Cee you" _
	#   $ declare -a parts
	#   declare -a parts=([0]="A part" [1]="Bee part" [2]="Cee you")
	#   $ var_parts_array_parse parts "A part:Bee part:Cee you"
	#   $ declare -a parts
	#   declare -a parts=([0]="A part" [1]="Bee part" [2]="Cee you")
	local __vpprs_name=$1
	local __vpprs_string=$2
	local __vpprs_sep=${3:-:}
	OFS=$IFS;IFS=:
	local __vpprs_parts=(${__vpprs_string})
	IFS=$OFS
	eval "$__vpprs_name=(\"\${__vpprs_parts[@]}\")"
}

function var_parts_array_join() {
	# Join an array into a string with optional separator
	# Example:
	#   $ parts=("A part" "Bee part" "Cee you")
	#   $ var_parts_array_join parts string _
	#   $ echo $string
	#   A part_Bee part_Cee you
	local __vpjn_name_src=$1
	local __vpjn_name_dst=$2
	local __vpjn_sep=${3:-:}
	local -a "__vpjn_parts=(\"\${$__vpjn_name_src[@]}\")"
	local __vpjn_string="${__vpjn_parts[0]}"
	for ((i=1;i<${#__vpjn_parts[@]};i++)); do
		__vpjn_string="$__vpjn_string$__vpjn_sep${__vpjn_parts[$i]}"
	done
	eval "$__vpjn_name_dst=\$__vpjn_string"
}


function var_parts_array_print() {
	# Print an array with optional separator
	# Example:
	#   $ parts=("A part" "Bee part" "Cee you")
	#   $ var_parts_array_print parts string _
	#   A part_Bee part_Cee you
	local __vpprn_name=$1
	local __vpprn_sep=${2:-:}
 	local __vpprn_string=hi
	var_parts_array_join "$__vpprn_name" __vprpn_string "$__vp_sep"
	echo "$__vprpn_string"
}

function var_parts_array_remove() {
	# Remove an exact entry from an array
	# Example:
	#   $ parts=("A part" "Bee part" "Cee you")
	#   $ var_parts_array_remove parts "Bee part"
	#   $ declare -p parts
	#   declare -a parts=([0]="A part" [1]="Cee you")
	local __vp_name=$1
	local __vp_string=$2
	local -a "__vp_parts=(\"\${$__vp_name[@]}\")"
	local i
	for ((i=${#__vp_parts[@]}-1;i>=0;i--))
		do
		[[ "${__vp_parts[$i]}" == "$__vp_string" ]] &&
			unset __vp_parts[$i]
	done
	eval "$__vp_name=(\"\${__vp_parts[@]}\")"
}

function var_parts_array_prepend() {
	# Prepend a string to an array provided by name
	local __vpap_name=$1
	local __vpap_string=$2
	eval "$__vpap_name=(\"\$__vpap_string\" \"\${$__vpap_name[@]}\")"
}

function var_parts_array_append() {
	# Append a string to an array provided by name
	local __vpaa_name=$1
	local __vpaa_string=$2
	eval "$__vpaa_name=(\"\${$__vpaa_name[@]}\" \"\$__vpaa_string\")"
}

function var_parts_prepend() {
	# Prepend a string to an array provided by name
	# Example:
	#   $ paths="path a:path b:multi path c"
	#   $ var_parts_prepend "path first" paths :
	#   $ echo $paths
	#   path first:path a:path b:multi path c
	local __vpsp_string=$1
	local __vpsp_name=${2:-PATH}
	local __vpsp_sep=${3:-:}
	local -a __vpsp_parts
	var_parts_array_parse __vpsp_parts "${!__vpsp_name}" "$__vpsp_sep"
	var_parts_array_remove __vpsp_parts "$__vpsp_string"
	var_parts_array_prepend __vpsp_parts "$__vpsp_string"
	var_parts_array_join __vpsp_parts "$__vpsp_name" "$__vpsp_sep"
	var_parts_log "Prepending to $__vpsp_name part: '$__vpsp_string'"
}

function var_parts_append() {
	# Append a string to an array provided by name
	# Example:
	#   $ paths="path a:path b:multi path c"
	#   $ var_parts_append "path last" paths :
	#   $ echo $paths
	#   path a:path b:multi path c:path last
	local __vpsp_string=$1
	local __vpsp_name=${2:-PATH}
	local -a __vpsp_parts
	var_parts_array_parse __vpsp_parts "${!__vpsp_name}"
	var_parts_array_remove __vpsp_parts "$__vpsp_string"
	var_parts_array_append __vpsp_parts "$__vpsp_string"
	var_parts_array_join __vpsp_parts "$__vpsp_name"
	var_parts_log " Appending to $__vpsp_name part: '$__vpsp_string'"
}

function var_parts_remove() {
	# Remove a component from a separated array, provided by name
	# Example:
	#   $ paths="path a:path delete:multi path c"
	#   $ var_parts_remove "path delete" paths :
	#   $ echo $paths
	#   path a:multi path c
	local __vpsp_string=$1
	local __vpsp_name=${2:-PATH}
	local -a __vpsp_parts
	var_parts_array_parse __vpsp_parts "${!__vpsp_name}"
	var_parts_array_remove __vpsp_parts "$__vpsp_string"
	var_parts_array_join __vpsp_parts "$__vpsp_name"
	var_parts_log "Removing from $__vpsp_name part: '$__vpsp_string'"
}

