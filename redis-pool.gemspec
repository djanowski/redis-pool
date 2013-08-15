require "./lib/redis/pool"

Gem::Specification.new do |s|
  s.name = "redis-pool"

  s.version = Redis::Pool::VERSION

  s.homepage = "https://github.com/djanowski/redis-pool"

  s.summary = "A Redis connection pool."

  s.authors = ["Damian Janowski"]

  s.email = ["jano@dimaion.com"]

  s.license = "Unlicense"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_dependency("connection_pool")
  s.add_dependency("redis")

  s.add_development_dependency("cutest")
end
