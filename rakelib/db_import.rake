#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :db do
  desc "Import supplied CSV files into the database (default csv/*.csv)"
  task :import, [:files] => [:environment, :datacenters] do |t, args|
    args.with_defaults(:files => "csv/*.csv")

    files = Dir.glob(args.files)

    if files.empty?
      abort "Error: you need to supply at least one CSV file to be imported."
    end

    require "power/analyzer"
    require "power/datacenter"
    require "power/importer"
    require "tire"
    require "batch"

    start = Time.now
    index = Tire.index "measurements"
    importer = Power::Importer.new(index)

    puts "[import] About to analyze and import #{files.size} CSV files... (#{start})"

    def archive(filename)
      # move file into archive folder
      archive_file = File.join(File.dirname(filename), "archive", File.basename(filename))

      # ensure target directory exists
      FileUtils.mkdir_p File.dirname(archive_file)
      FileUtils.mv filename, archive_file
    end

    Batch.each(files) do |filename|
      unless File.exists?(filename)
        raise RuntimeError, "Unable to find #{filename}, skipping."
        next
      end

      # file will be closed by Analyzer
      analyzer = Power::Analyzer.new

      file = File.open(filename, "r")
      analyzer.analyze(file)

      if analyzer.entries.any?
        entries = analyzer.entries

        while entries.any?
          batch = entries.shift(200)

          importer.import batch
        end
      else
        # archive empty file
        archive filename
        raise RuntimeError, "No entries found to be imported."
        next
      end

      # archive successful/processed file
      archive filename
    end

    duration = Time.now - start

    puts "[import] Done. Took #{duration}"
  end
end
