#!/bin/bash
#
# This is a script to simplify some of the common tasks running jekyll
#
# start
#
#   Start jekyll locally
#
# stop
#
#   Stop jekyll
#
# post "<title>" 
#
#   Create a new jekyll post
#
# draft "<title>"
#   

post_dir="_posts"
draft_dir="_drafts"

pid_file=".run-jekyll.pid"

function usage {
    echo $"Usage: $0 {start|stop|restart|post}"
}

function check {
	local pid

	process=$(ps -ax | grep -v 'grep' | grep 'jekyll serve')
	if [ "x${process}" != "x" ]; then
		pid=$(echo "$process" | awk '{print $1}')
		echo "$pid"
	fi
	return
}

function start {
	old_pid=$(check)
	if [ "x${old_pid}" != "x" ]; then
		echo "Found stale jekyll process ... (killing pid $old_pid)"
		kill "$old_pid"
		[ -f "$pid_file" ] && rm -f "$pid_file"
	fi
    echo -n "Starting jekyll ... "
    cfg="_config.yml"
    [ -f "_config_dev.yml" ] && cfg="$cfg,_config_dev.yml"
    bundle exec jekyll serve --config "$cfg" &
    pid=$!
    echo "$pid" > "$pid_file"
    echo "(pid $pid)"
}

function stop {
    echo -n "Stopping jekyll ... "
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        echo "(pid $pid)"
        kill -TERM "$pid"
        rm -f "$pid_file"
    else
        echo " no PID file found!"
    fi
}

function post {
	cat <<-EOT
	---
	layout: post
	title: $yaml_title
	date: $yaml_date
	comments: yes
	tags:
	  - draft
	category:
	  - Draft
	---
EOT
}

if [ "x$1" != "x" ]; then
    case "$1" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            stop
            start
            ;;
        post)
			if [ "x$2" == "x" ]; then
				yaml_title="New Post"
			else
				yaml_title="$2"
			fi
			yaml_date=$(date "+%Y-%m-%d %H:%M:%S %z")
			out_slug=$(echo $yaml_title | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z)
			out_date=$(date "+%Y-%m-%d")
			out_file="_posts/${out_date}-${out_slug}.md"
			post > "$out_file"
			echo -ne "\nCreated\n  $out_file\n\n"
			;;			
        *)
            usage
            ;;
    esac
else
    usage
fi
