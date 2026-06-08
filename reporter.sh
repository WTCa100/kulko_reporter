#!/bin/bash

PROGNAME="$(basename $0)"

usage()
{
    echo "Usage: $PROGNAME [[-f|--filename] <filename> | [-i|--interactive] | [-h|--help]]"
    return
}

get_uptime()
{
    echo "$(uptime) ($(uptime -p))"
}

get_disk_space()
{
    printf '%b' "$(df -h / /boot/efi)"
}

get_home_disk_utility()
{
    echo -e "$(du -hs --time $1) " &2>/dev/null
}

write_html_file()
{
    home_dir=
    if (( "$(id -u)" == 0 )); then
        home_dir="/home"
    else
        home_dir=$HOME
    fi

    # at this point filename must be present no need for additional checks
    cat << _EOF_
<html>
<head>
    <title>$(basename $filename)</title>
    <style>
        body {
            margin-right: 10%
        }
        div {
            border: thick double
        }
    </style>
</head>
<body>
    <h1>Report triggered for user: $USER</h1>
    <hr>
    <div>
    <pre>$(get_uptime)</pre>
    </div>
    <div>
        <pre>$(get_disk_space)</pre>
    </div>
    <div>
        <pre>$(get_home_disk_utility $home_dir)</pre>
    </div>
</body>
</html>
_EOF_
}


interactive=
filename=

if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
fi

# Can also use while getopts :f:ih opt; 
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h|--help)
                 usage
                 exit
                 ;;
    -f|--filename)
                 shift
                 if [[ -z $1 ]]; then
                    echo "Missing positional argument for path!" >&2
                    usage >&2
                    exit 1
                 fi
                 filename="$1"
                 shift
                 ;;
    -i|--interactive)
                 interactive=1
                 shift
                 ;;
    *)
        echo "Invalid param! $1" >&2
        usage >&2
        exit 1
    esac
done

if [[ -n $interactive ]]; then
    if [[ -z $filename ]]; then
        read -r -p "Please provide a path for your report: " filename
        filename="$(pwd)/$filename"
    fi

    if [[ -f $filename ]]; then
        overwrite=
        while [[ -z $overwrite ]]; do
            read -r -p "Provided file already exists. Overwrite? [y/n/q] "
            case $REPLY in 
                y|Y) overwrite=1;;
                n|N)
                     date_full="$(date +"%x %r %Z")"
                     date_formated="$(date -d "$date_full" "+%Y%m%d%H%M%S")"
                     filename="system_report_$date_formated.html"
                     echo "Will use default file name for report: $filename"
                     filename="$(pwd)/$filename"
                     overwrite=0
                     ;;
                q|Q)
                     echo "Aborting report dump..."
                     exit 0
                     ;;
                *) echo ??;;
            esac
        done
    fi
fi


((write_html_file) > $filename && echo "Report done") || write_html_file
