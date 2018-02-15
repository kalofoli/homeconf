#! /bin/bash


function usage() {
cat <<EOF
$0
	-h               This help message.
	-r ROOT_PATH     The destination root path (Default: $root_path).
	-n               Dry run. Do not perform any changes, just print the commands to be done.
EOF
}

function log() {
	if [ "$debug" == "yes" ]; then echo "$@" >&2 ; fi
}

root_path=~/.local-roots/dpkg
dry_run=no
debug=no

OPTSTRING=":hr:nd"

while getopts $OPTSTRING opt; do
case $opt in
	h) usage; exit;;
	r) root_path=$OPTARG;;
	n) dry_run=yes;;
	d) debug=yes;;
	\?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1;;
esac
done

shift $((OPTIND-1))


if [ "$dry_run" == "yes" ]; then
	cmd_mkdir="echo mkdir -p"
	cmd_ln="echo ln -s"
else
	cmd_mkdir="mkdir -p"
	cmd_ln="ln -sf"
fi

. ~/.bashrc.d/01-install-roots.sh


function link_package() {
	package_root=$(resolve_directory_path "$1")
	[ -z "$package_root" ] && 
	echo "No package is specified" >&2 &&
	exit 1
	
	
	log -n 'Installing package "'$( basename "$package_root")'"'
	package_file_string=$( find "$package_root" -type d -printf "%P\n" ) || ( 
		echo Cannot list the directories of the package
		exit 1
	)
	OFS=$IFS;IFS=$'\n';package_dirs=($package_file_string);IFS=$OFS
	
	
	package_file_string=$( find "$package_root" \! -type d -printf "%P\n" ) || ( 
		echo Cannot list the files of the package
		exit 1
	)
	OFS=$IFS;IFS=$'\n';package_files=($package_file_string);IFS=$OFS
	
	log -n " dirs... "
	pushd "$root_path" >/dev/null &&
	$cmd_mkdir "${package_dirs[@]}" &&
	popd >/dev/null
	if [ $? -ne 0 ] ; then 
		echo Cannot make directories >&2
		exit 1
	fi
	
	log -n " links: "
	pushd "$root_path" >/dev/null &&
		for each in "${package_files[@]}"; do
			$cmd_ln "$package_root/$each" "$root_path/$each"
			log -n .
		done &&
	popd >/dev/null
	log -e ' Done'
	
}

log "Linking into root path: '$root_path'"
for each in "$@"; do
	link_package "$each"
done


