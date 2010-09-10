require 'logslam'
require 'zlib'
require 'stringio' 

module LogslamClient
  DEFAULT_HOST = "127.0.0.1"
  DEFAULT_PORT = 8089

  COMMANDS = {
    :list => "LIST",
    :get => "GET",
    :auth => "AUTHENTICATE",
    :interactive => "INTERACTIVE"
  }

  def self.pager
    return if PLATFORM =~ /win32/
    return unless STDOUT.tty?
    
    read, write = IO.pipe
    
    unless Kernel.fork # Child process
      STDOUT.reopen(write)
      STDERR.reopen(write) if STDERR.tty?
      read.close
      write.close
      return
    end
    
    # Parent process, become pager
    STDIN.reopen(read)
    read.close
    write.close
    
    ENV['LESS'] = 'FSRX' # Don't page if the input is short enough
    
    Kernel.select [STDIN] # Wait until we have input before we start the pager
    pager = ENV['PAGER'] || 'less'
    exec pager rescue exec "/bin/sh", "-c", pager
  end
  
  def post_init
    start_tls
  end
  
  def receive_data data
    puts data
  end
  
  def send_command data
    send_data "#{data}\r\n"
  end

  def self.run(options)
    host, port = options[:host], options[:port]
    host ||= DEFAULT_HOST
    port ||= DEFAULT_PORT

    EM.run {
      $conn = EM.connect host, port, LogslamClient
      if options[:interactive]
        EM.open_keyboard(Keyboard)
      else
        if options[:list]
          command = COMMANDS[:list]
        elsif options[:logfile]
          command = "#{COMMANDS[:get]} #{options[:logfile]} #{options[:lines]}"
        else
          exit
        end

#        $conn.send_command "#{COMMANDS[:auth]} #{options[:username]}:#{options[:password]}"
        $conn.send_command "#{COMMANDS[:interactive]} false"
        pager
        $conn.send_command command
      end
    }
  end
  
  def unbind
    EM.stop_event_loop
  end
end

module Keyboard
  include EM::Protocols::LineText2
  def receive_line data
    $conn.send_command data
    $stdout.flush
  end
end
