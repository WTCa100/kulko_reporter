#!/bin/bash

PROGNAME="$(basename $0)"

usage()
{
    echo "Usage: $PROGNAME [[-f|--filename] <filename> | [-i|--interactive] | [-h|--help]]"
    return
}

get_uptime()
{
    echo "<h3>Uptime</h3>"
    echo "<pre>$(uptime) ($(uptime -p))</pre>"
}

get_disk_space()
{
    echo "<h3>Disk usage</h3>"
    echo "<pre>$(df -h / /boot/efi 2>/dev/null)</pre>"
}

get_home_disk_utility()
{
    FORMAT="%s\t%s\t%s\n"
    dir_list=
    if (( "$(id -u)" == 0 )); then
        dir_list="/home/*"
    else
        dir_list=$HOME
    fi

    echo "<h3>Home disk utility</h3>"

    for i in $dir_list; do
        echo "<h4>$i</h4>"
        echo "<pre>"
        total_files="$(find "$i" -type f | wc -l)"
        total_dirs="$(find "$i" -type d | wc -l)"
        total_size="$(du -sh "$i" | cut -f 1)"
        printf "$FORMAT" "Files" "Dirs" "Size"
        printf "$FORMAT" "-----" "----" "----"
        printf "$FORMAT" "$total_files" "$total_dirs" "$total_size"
        echo "</pre>"
    done
}

write_html_file()
{
    # at this point filename must be present no need for additional checks
    cat << _EOF_
<html>
<head>
    <title>$(basename "$filename")</title>
    <style>
        body {
            margin-right: 10%
        }
        div {
            border: thick double;
            padding-left: 10px
        }
    </style>
</head>
<body>
    <h1>Report triggered for user: $USER</h1>
    <hr>
    <div>
        $(get_uptime)
    </div>
    <div>
        $(get_disk_space)
    </div>
    <div>
        $(get_home_disk_utility)
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
                [yY]) overwrite=1;;
                [nN])
                     date_full="$(date +"%x %r %Z")"
                     date_formated="$(date -d "$date_full" "+%Y%m%d%H%M%S")"
                     filename="system_report_$date_formated.html"
                     echo "Will use default file name for report: $filename"
                     filename="$(pwd)/$filename"
                     overwrite=0
                     ;;
                [qQ])
                     echo "Aborting report dump..."
                     exit 0
                     ;;
                *) echo ??;;
            esac
        done
    fi
fi


( (write_html_file) > $filename && echo "Report done") || write_html_file
