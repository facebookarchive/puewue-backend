#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "bundler"
rack_env = ENV.fetch("RACK_ENV", "development").to_sym
Bundler.setup(:default, rack_env)

# ensure our application is in the $LOAD_PATH
libdir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "rake/testtask"
require "rake/clean"

CLEAN.push "coverage"

# Load environment variables from .env files
# (gives priority to local files too)
task :environment do
  require "dotenv"
  Dotenv.load ".env.#{rack_env}", ".env"
end

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end
task :default => :spec

desc "Run tests for spec with coverage"
task "spec:coverage" do
  ENV["COVERAGE"] = "true"
  Rake::Task["spec"].invoke
end

desc "Run a interactive console (IRB)"
task :console => :environment do
  ARGV.clear

  require "irb"
  IRB.start
end
