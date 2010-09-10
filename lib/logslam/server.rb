require 'logslam'
require 'socket'

module LogslamServer
    COMMANDS = {
      "GET" => :get,
      "LIST" => :list,
      "EXIT" => :quit,
      "QUIT" => :quit,
      "GOODBYE" => :quit,
      "AUTHENTICATE" => :authenticate,
      "INTERACTIVE" => :interactive
    }

    DEFAULT_HOST = "0.0.0.0"
    DEFAULT_PORT = 8089
      
    def initialize(directory)
      super
      @directory = directory
    end
      
    def self.run(options)
      host, port = options[:host], options[:port]
      host ||= DEFAULT_HOST
      port ||= DEFAULT_PORT
      exit unless options[:directory]
      EM.run {
        EM.epoll
        EM.start_server host, port, LogslamServer, options[:directory]
        puts "Listening on #{host}:#{port}"
      }
    end
    
    def post_init
      start_tls
      port, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "#{Time.now.strftime("%H:%M:%S %D")} Connection from #{@ip}"
      @authenticated = true # Set to false when auth method is readded
      @interactive = true
    end
    
    def receive_data(data)
      # parse input into command and arguments
      first_space = data.index(" ") || -1
      command = data[0...first_space].chomp
      arguments = data[(first_space + 1)..-1].chomp
      
      # look up what to do with command
      method = COMMANDS[command]
      
      if @authenticated || :authenticate == method
        if method
          # run it with arguments
          send(method, arguments)
        else
          send_data "Invalid command\n"
          send_data "Available commands are #{COMMANDS.keys.join(", ")}\n"
        end
      else
        send_data "Please authenticate: AUTHENTICATE username:password\n"
      end
      # Crude logging
      puts "#{Time.now.strftime("%H:%M:%S %D")} #{data}" unless method == :authenticate
      
      # Close the connection if its not interactive
      close_connection_after_writing unless @interactive || method == :interactive || method == :get
    end
    
    def unbind
      puts "#{Time.now.strftime("%H:%M:%S %D")} Disconnect from #{@ip}"
    end

    def authenticate(args)
      username, password = args.split(":")
      if username && password
        response = AUTH.authenticated?(username, password) # dummy module
        if response
          @authenticated = true
        else
          send_data "Authentication Failed\n"
        end
      else
        send_data "username or password is blank\n"
      end
    end
    
    def interactive(args)
      if args == "false"
        @interactive = false
      else
        @interactive = true
      end
    end

    def quit(args)
      close_connection
    end

    def list(args)
      send_data "#{logs.join("\n")}\n"
    end
    
    def logs
      Dir["#{@directory}/**/*.log"].map do |file|
        file[(@directory.length + 1)..-1]
      end
    end
    
    def get(args)
      log, lines = args.split(" ")
      lines = lines[/^(\d+)$/, 1] if lines

      if logs.include?(log)
        if lines
          f = Tail.new("#{@directory}/#{log}")
          f.tail(lines.to_i) { |line| send_data line }
          f.callback { close_connection_after_writing }
        else
          streamer = EventMachine::FileStreamer.new(self, "#{@directory}/#{log}")
          streamer.callback { close_connection_after_writing }
        end 
      end
    end  
end
