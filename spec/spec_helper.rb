# force test environment
ENV["RACK_ENV"] = "test"

require "bundler"
Bundler.setup(:default, :test)

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/vendor/bundle"
  end
end

# load test-specific environment variables
require "dotenv"
Dotenv.load ".env.test", ".env"

require "minitest/autorun"
require "rack/test"

require "minitest/ansi"
MiniTest::ANSI.use!

# Allow usage of 'context' like 'describe'
module MiniTest
  class Spec
    class << self
      alias_method :context, :describe
    end
  end
end
