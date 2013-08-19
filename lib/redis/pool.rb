require "connection_pool"
require "redis"

class Redis::Pool < Redis
  VERSION = "0.1.0"

  attr :pool

  def initialize(options = {})
    @pool = ConnectionPool.new(size: options.delete(:size)) { Redis::Client.new(options) }
    @id = "Redis::Pool::#{object_id}"

    super
  end

  def synchronize
    if current = Thread.current[@id]
      yield(current)
    else
      @pool.with do |client|
        _with_client(client) { yield(client) }
      end
    end
  end

  def pipelined
    pipeline = Pipeline.new

    _with_client(pipeline) do |client|
      yield(client)
    end

    synchronize do |client|
      client.call_pipeline(pipeline)
    end
  end

  def multi
    raise ArgumentError, "Redis::Pool#multi can only be called with a block" unless block_given?
    super
  end

protected

  def _with_client(client)
    old, Thread.current[@id] = Thread.current[@id], client
    yield(client)
  ensure
    Thread.current[@id] = old
  end
end
