#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :sftp do
  desc "Fetch CSV files and store as Data files for further processing"
  task :fetch => :environment do
    require "power/data_file"
    require "net/sftp"
    require "batch"

    url = URI.parse(ENV.fetch("SFTP_URL"))
    host, user, directory = url.host, url.user, url.path
    key_path = ENV.fetch("SFTP_KEY")

    unless [host, user, directory, key_path].all?
      abort "SFTP_HOST, SFTP_USER, SFTP_DIR and SFTP_KEY are required."
    end

    # read key file
    key_data = File.read(key_path)

    start = Time.now

    Net::SFTP.start(host, user, :key_data => key_data) do |sftp|
      puts "[fetch] Collecting CSV files from '#{directory}'... (#{start})"

      # retrieve all the files in the directory
      entries = sftp.dir.glob(directory, "*.csv")

      if entries.empty?
        puts "Nothing to download, exiting."
        break
      end

      # determine unique files (that haven't been downloaded)
      new_entries = entries.reject { |entry|
        Power::DataFile.imported?(entry.name)
      }

      puts "Found #{entries.size} CSV files, about to fetch #{new_entries.size} new..."

      Batch.each(new_entries) do |entry|
        # build remote filename
        remote_path = File.join(directory, entry.name)
        archive_path = File.join(directory, "archive", entry.name)

        # download file content and store
        blob = sftp.download!(remote_path)
        data_file = Power::DataFile.create(:filename => entry.name, :blob => blob)

        # move file around
        # sftp.rename!(remote_path, archive_path)
      end

      duration = Time.now - start

      puts "[fetch] Done fetching. Took #{duration}"
    end
  end
end
