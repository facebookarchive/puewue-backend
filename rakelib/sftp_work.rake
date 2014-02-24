#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :sftp do
  desc "Process (import) fetched CSV from Data file"
  task :work => [:environment, :datacenters] do
    require "power/data_file"
    require "power/analyzer"
    require "power/datacenter"
    require "power/importer"
    require "tire"
    require "batch"

    start = Time.now
    index = Tire.index "measurements"
    importer = Power::Importer.new(index)

    puts "[work] Checking pending Data files... (#{start})"

    data_files = Power::DataFile.pending

    if data_files.size > 0
      puts "About to analyze and import #{data_files.size} CSV files..."

      Batch.each(data_files) do |data_file|
        analyzer  = Power::Analyzer.new

        # mark as being processed
        data_file.process!

        # analyze the entries
        analyzer.analyze(data_file.contents)

        if analyzer.entries.any?
          entries = analyzer.entries

          while entries.any?
            batch = entries.shift(200)

            importer.import batch
          end
        else
          # archive empty file
          data_file.complete!
          raise RuntimeError, "No entries found to be imported."
          next
        end

        data_file.complete!
      end
    end

    duration = Time.now - start

    puts "[work] Done. Took #{duration}"
  end
end
