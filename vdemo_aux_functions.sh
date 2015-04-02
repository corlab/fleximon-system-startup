function vdemo_get_logdir {
    local VDEMO_demoid="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]##*/}"
    if [ "$VDEMO_demoid" = "vdemo2" ]; then
        VDEMO_demoid="${BASH_SOURCE[${#BASH_SOURCE[@]}-2]##*/}"
    fi
    echo "/tmp/vdemo-$USER-${VDEMO_demoid%.sh}"
}

function vdemo_gdbbacktrace {
    tracelog="${VDEMO_logfile_prefix}${0##*/}_trace.log"
    date +"++++ %Y-%m-%d %T ++++" >> "$tracelog"
    echo "$@" >> "$tracelog"
    gdb -q -n -return-child-result -ex "set confirm off" -ex "set logging file $tracelog" -ex "set logging on" -ex "set logging redirect on" -ex "handle SIGTERM noprint nostop" -ex "set pagination off" -ex run -ex "thread apply all bt" -ex "quit" --args "$@"
    date +$'---- %Y-%m-%d %T ----\n' >> "$tracelog"
}
export -f vdemo_gdbbacktrace

function vdemo_coredump {
    coredumpdir="$VDEMO_logdir/${0##*/}"
    mkdir -p "$coredumpdir" && cd "$coredumpdir" && ulimit -c unlimited && "$@"
}
export -f vdemo_coredump

function vdemo_inspect_cmd {
    rsb-loggercl0.11 -s timeline/scope "spread:$OUTSCOPE"
    echo "***logger terminated***"
    read
}
export -f vdemo_inspect_cmd
