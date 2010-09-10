# Logslam: Centralized remote log streaming server and client

Logslam is written in ruby with eventmachine. It provides remote access to log files 
without needing ssh access to the server.

## Install

    gem install logslam

## Starting the server

    logslam -s -d /tmp -D

## Running the client

    logslam -H [server] --list
