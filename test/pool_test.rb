require "cutest"

$VERBOSE = 1

require_relative "../lib/redis/pool"

at_exit do
  if $redis
    Process.kill(:TERM, $redis)
  end

  Process.waitpid
end

$redis = spawn("redis-server --port 9999 --logfile /dev/null")

def teardown(r)
  r.pool.shutdown(&:disconnect)
end

setup do
  Redis::Pool.new(port: 9999, size: 10)
end

test "Pool" do |r|
  threads = Array.new(100) do
    Thread.new do
      10.times do
        r.get("foo")
      end
    end
  end

  threads.each(&:join)

  assert_equal "10", r.info["connected_clients"]

  teardown(r)
end

test "Pipelining" do |r|
  threads = Array.new(100) do
    Thread.new do
      10.times do
        r.pipelined do
          r.set("foo", "bar")

          r.pipelined do
            r.del("foo")
          end
        end
      end
    end
  end

  threads += Array.new(100) do
    Thread.new do
      10.times do
        r.multi do
          r.set("foo", "bar")
          r.del("foo")
        end
      end
    end
  end

  threads.each(&:join)

  assert_equal "10", r.info["connected_clients"]
  assert_equal nil, r.get("foo")

  teardown(r)
end

test "MULTI fails when no block given" do |r|
  assert_raise(ArgumentError) do
    r.multi
  end

  teardown(r)
end
