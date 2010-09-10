require 'daemons'
require 'fileutils'

class Launcher
  def initialize(options = {})
    @options = options 
  end

  def self.daemonize(options = {})
    d = Launcher.new(options)
    d.remove_stale_pid_file
    Daemonize.daemonize(File.expand_path(options[:server_log]))
    Dir.chdir(options[:directory])
    d.write_pid_file
  end

  def remove_pid_file
    File.delete(p) if @options[:pid_file] && File.exists?(@options[:pid_file])
  end
  
  def write_pid_file
    puts ">> Writing PID to #{@options[:pid_file]}"
    FileUtils.mkdir_p File.dirname(@options[:pid_file])
    open(@options[:pid_file],"w") { |f| f.write(Process.pid) }
    File.chmod(0644, @options[:pid_file])
  end
  
  # If PID file is stale, remove it.
  def remove_stale_pid_file
    if File.exists?(@options[:pid_file])
      if pid && Process.running?(pid)
        raise PidFileExist, "#{@options[:pid_file]} already exists, seems like it's already running (process ID: #{pid}). " +
          "Stop the process or delete #{@options[:pid_file]}."
      else
        log ">> Deleting stale PID file #{@options[:pid_file]}"
        remove_pid_file
      end
    end
  end
end
