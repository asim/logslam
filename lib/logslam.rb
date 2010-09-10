require 'eventmachine'
require 'highline/import'
require 'logslam/client.rb'
require 'logslam/server.rb'
require 'logslam/auth.rb'
require 'logslam/tail.rb'
require 'logslam/launcher.rb'

module Logslam
  def self.run(options)
    # Self defined defaults
    options[:server_log] = "logslam.log" 
    options[:pid_file] = "logslam.pid"

    if options[:configfile]
      if File.exists?(options[:configfile]) 
        new_opts = YAML.load_file(options[:configfile])
        options[:directory] = new_opts["directory"]
        options[:host] = new_opts["host"]
        options[:port] = new_opts["port"]
        options[:daemonize] ||= new_opts["daemonize"]
        options[:server] = true
      else
        puts "Config File #{options[:configfile]} does not exist"
        exit
      end
      Launcher.daemonize(options) if options[:daemonize]
      LogslamServer.run(options)
    elsif options[:server]
      Launcher.daemonize(options) if options[:daemonize]
      LogslamServer.run(options)
    else
      LogslamClient.run(options)
    end
  end
end
