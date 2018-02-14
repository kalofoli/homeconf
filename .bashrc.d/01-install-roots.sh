

#### Resolve the absolute path of a directory
# resolve_directory_path DIRPATH
# 
# Returns the absolute path of the specified directory, if it exists.
# If the path does not exist, the function silently fails.
function resolve_directory_path() {
	pushd "$1" &>/dev/null &&
	expansion=$(pwd -P) &&
	popd &>/dev/null &&
	echo "$expansion" 
}

install_root_config="
PATH bin
PATH usr/bin
PATH sbin
PATH usr/sbin
LD_LIBRARY_PATH lib
LD_LIBRARY_PATH usr/lib
PKG_CONFIG_PATH lib/pkgconfig
"
OFS=$IFS;IFS=$'\n';install_root_config=($install_root_config);IFS=$OFS


#### Install a root environment using appropriate settings of local variables
# install_root PREFIX [SIDE]
# 
#     side:  can be "append" or "prepend" and specifies whether the new variable is prepended or appended to the existing 
#            environment variable (Default: prepend).
#
# The PREFIX is converted to the absolute path, and then all subdirs in install_root_config are appended to the respective 
# environment variable, if the subdirectory exists.
# In case the entry is already in the environment variable, it is moved to the specified location (according to the side argument).
function install_root() {
	local prefix
	local side=${2:-prepend}
	prefix=$(resolve_directory_path "$1") || return 1
	# echo "Installing root: \"$prefix\""
	local config
	for config in "${install_root_config[@]}"; do
		local config_parts=($config)
		local var=${config_parts[0]}
		local path="$prefix/${config_parts[1]}"
		[ -d "$path" ] &&
		eval var_parts_$side "$path" $var
		eval export $var
	done
}

#### Uninstall a root environment
# uninstall_root PREFIX
#
# Uninstalls the root environment by removing its subdirectories from the environment variables.
function uninstall_root() {
	local prefix
	prefix=$(resolve_directory_path "$1") || return 1
	# echo "Uninstalling root: \"$prefix\""
	local config
	for config in "${install_root_config[@]}"; do
		local config_parts=($config)
		local var=${config_parts[0]}
		local path="$prefix/${config_parts[1]}"
		var_parts_remove "$path" $var
	done
}

