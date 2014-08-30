#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :db do
  desc "Seed index with fake measurements"
  task :populate, [:days] => [:environment, :datacenters] do |t, args|
    require "power/datacenter"
    require "power/analyzer/entry"
    require "power/analyzer/point_builder"
    require "power/importer"
    require "tire"

    class Timestamp < Struct.new(:time)
      def to_lucene
        time.strftime("%Y-%m-%dT%H:%M:%S")
      end

      def to_i
        time.to_i
      end
    end

    args.with_defaults(:days => "5")

    # entries per day
    per_day = 1_440

    # possible ranges
    pue_range         = (1.01)..(1.02)
    wue_range         = (0.41)..(0.42)
    humidity_range    = (23.01)..(23.02)
    temperature_range = (44.05)..(44.08)
    util_kwh_range    = (55.00)..(180.00)
    it_kwh_range      = (45.00)..(150.00)
    total_water_range = (0.0)..(123.0)
    names             = ["Timestamp", "PUE", "WUE", "Temp", "humidity",
                          "UtilKWh", "ITKWh", "TotaWaterUsage"]
    datacenters       = Power::Datacenter.all

    hour = 3_600
    day  = 86_400
    days = args.days.to_i

    # between days ago and tomorrow
    now = Time.now.utc
    start_date = now - (days * day)
    end_date   = now + day

    entries = []

    puts "Building fake entries..."

    current = start_date
    while current < end_date
      start_hour = current - (current.min * 60) - current.sec

      builder = Power::Analyzer::PointBuilder.new(names)

      60.times do |offset|
        timestamp = Time.at(start_hour + (offset * 60))

        datacenters.each do |datacenter|
          values = [
            timestamp.to_s,
            rand(pue_range).round(2),
            rand(wue_range).round(2),
            rand(temperature_range).round(2),
            rand(humidity_range).round(2),
            rand(util_kwh_range).round(2),
            rand(it_kwh_range).round(2),
            rand(total_water_range).round(2)
          ]

          points = builder.build(values)
          entry  = Power::Analyzer::Entry.new(datacenter, points)

          entries.push entry
        end
      end

      current += hour
    end

    puts "Computed #{entries.size} fake entries."

    puts "About to import entries into index..."

    index = Tire.index "measurements"
    importer = Power::Importer.new(index)

    while entries.any?
      batch = entries.shift(200)

      importer.import batch

      print "."
      $stdout.flush
    end

    puts "\nDone importing."
  end
end
