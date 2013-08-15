Redis::Pool
===========

A Redis connection pool.

Usage
-----

    require "redis/pool"

    $redis = Redis::Pool.new(size: 10)

    Array.new(100) do
      Thread.new do
        $redis.get("foo")
      end
    end.each(&:join)

    $redis.info["connected_clients"]
    # => 10
