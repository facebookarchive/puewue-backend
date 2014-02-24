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

# Load environment variables from .env files
# (gives priority to local files too)
require "dotenv"
Dotenv.load ".env.#{rack_env}", ".env"

require "power"

map "/" do
  run Power::Application
end
