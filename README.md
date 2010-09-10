# Logslam: Centralized remote log streaming server and client

Logslam is written in ruby with eventmachine. It provides remote access to log files 
without needing ssh access to the server.

## Install

    gem install logslam

## Usage

    Usage: logslam [options]
        -c, --config-file FILE           Config file to run server
        -D, --daemonize                  Daemonize logslam when running the server
        -d, --dir DIRECTORY              The directory logs files are in
	-g, --get FILE                   Specify name of log file
    	-h, --host HOST                  Host to connect to or run on as server (default: 0.0.0.0)
    	-i, --interactive                Operate in interactive mode
    	-l, --list                       List available log files
    	-n, --lines LINES                Number of lines to tail
    	-P, --port PORT                  Port to connect to or run as server (default: 8089)
    	-p, --password [password]
    	-u, --username USERNAME
    	-s, --server                     Run a LogslamServer
        --help

    Example:
        client: /usr/bin/logslam --get logfile --username foo --password bar
        server: /usr/bin/logslam -s -H localhost -P 8089 -d /tmp


    Credentials can be stored in ~/.logslam in YAML format:
        username: foo
        password: bar
        host: baz

## Quickstart Server:

The following command will start a server in the foreground and serve files from /tmp. Use -D to daemonize.

    logslam -s -d /tmp

## Quickstart Client:

    list files:
    logslam -l

    get file:
    logslam -g [filename]

    get last 10 lines of file:
    logslam -g [filename] -n 10