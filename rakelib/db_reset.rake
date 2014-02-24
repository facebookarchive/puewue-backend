#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :db do
  desc "Reset database contents. Set force to 'yes' to confirm."
  task :reset, [:force] => :environment do |t, args|
    rack_env = ENV.fetch("RACK_ENV", "development")
    args.with_defaults(:force => (rack_env == "development"))

    if args.force
      Rake::Task['db:reset:tire'].invoke
    else
      abort "Error: you need to `force` to clear database in this environment."
    end
  end

  namespace :reset do
    task :tire => :environment do
      require "tire"

      puts "Resetting ElasticSearch index..."

      index = Tire.index "measurements"
      index.delete
    end
  end
end
