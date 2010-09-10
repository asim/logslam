class Tail
  def initialize(filename)
    @filename = filename
  end

  def position(n = 0)
    if n <= 0
      @file.seek(0, File::SEEK_END)
      return self
    end
  
    bufsiz = 8192
    size = @file.stat.size
    begin
      if bufsiz < size
        @file.seek(0, File::SEEK_END)
        while n > 0 and @file.tell > 0 do
          start = @file.tell
          @file.seek(-bufsiz, File::SEEK_CUR)
          buffer = @file.read(bufsiz)
          n -= buffer.count("\n")
          @file.seek(-bufsiz, File::SEEK_CUR)
        end
      else
        @file.seek(0, File::SEEK_SET)
        buffer = @file.read(size)
        n -= buffer.count("\n")
        @file.seek(0, File::SEEK_SET)
      end
    rescue Errno::EINVAL
      size = @file.tell
      retry
    end
    pos = -1
    while n < 0  # forward if we are too far back
      pos = buffer.index("\n", pos + 1)
      n += 1
    end
    @file.seek(pos + 1, File::SEEK_CUR)
    self
  end

  def tail(lines, &block)
    begin
      @file = File.new(@filename)
    rescue Errno::ENOENT
      # no file found
      raise
    end
    
    position(lines)
    
    @n = lines
    @naptime = 0;
    @block = block
    read
  end

  def callback(&block)
    @callback = block
    @callback.call if @succeeded
  end

  def set_status(status)
    @succeeded = status
    case @succeeded
    when :succeeded
      @callback.call if @callback
    end
  end

  def read
    begin
      until @n == 0
        @naptime = 0
        @block.call @file.readline
        
        @n -= 1
        EventMachine::next_tick {read}       
      end
      set_status :succeeded
    rescue EOFError
      @file.seek(0, File::SEEK_CUR)
      raise ReturnException
    end
  end
end
