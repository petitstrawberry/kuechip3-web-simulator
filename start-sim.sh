#!/bin/sh

set -eu

PORT=8001
URI="http://localhost:${PORT}/kuesim.html"


# start http-server
if   which python3   >/dev/null 2>&1; then      # python3
    if ps | grep python3 >/dev/null 2>&1; then
        echo 'http server is already started'
    else
        python3 -m http.server $PORT &
        echo 'start server'
    fi
elif which python    >/dev/null 2>&1; then      # python2
    if ps | grep python >/dev/null 2>&1; then
        echo 'http server is already started'
    else
        python -m SimpleHTTPServer $PORT &
        echo 'start server'
    fi
fi


sleep 0.2


# open web interface of simulator
if   which xdg-open   >/dev/null 2>&1; then  # Linux
    xdg-open $URI
elif which gnome-open >/dev/null 2>&1; then  # Linux (gnome)
    gnome-open $URI
elif which open       >/dev/null 2>&1; then  # Mac  
    open $URI
elif which cygstart   >/dev/null 2>&1; then  # Cygwin 
    cygstart $URI
fi
