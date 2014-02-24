#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

namespace :sftp do
  desc "Download CSV files via SFTP into a directory (default: csv)"
  task :download, [:target] => :environment do |t, args|
    args.with_defaults(:target => "csv")

    require "net/sftp"
    require "batch"

    # ensure target exists
    target = args.target
    archive = File.join(target, "archive")

    FileUtils.mkdir_p target
    FileUtils.mkdir_p archive

    url = URI.parse(ENV.fetch("SFTP_URL"))
    host, user, directory = url.host, url.user, url.path
    key_path = ENV.fetch("SFTP_KEY")

    unless [host, user, directory, key_path].all?
      abort "SFTP_HOST, SFTP_USER and SFTP_DIR and SFTP_KEY are required."
    end

    # read key file
    key_data = File.read(key_path)

    start = Time.now

    Net::SFTP.start(host, user, :key_data => key_data) do |sftp|
      puts "[download] Collecting CSV files from '#{directory}'... (#{start})"

      # retrieve all the files in the directory
      entries = sftp.dir.glob(directory, "*.csv")

      if entries.empty?
        puts "Nothing to download, exiting."
        break
      end

      # determine unique files (that haven't been downloaded)
      new_entries = entries.reject { |entry|
        target_file  = File.join(target, entry.name)
        archive_file = File.join(archive, entry.name)

        File.exist?(target_file) || File.exist?(archive_file)
      }

      puts "Found #{entries.size} CSV files, about to download #{new_entries.size} new..."

      Batch.each(new_entries) do |entry|
        # build remote and target filename
        remote_path = File.join(directory, entry.name)
        local_path  = File.join(target, entry.name)
        temp_path   = File.join(target, "#{entry.name}.tmp")

        sftp.download!(remote_path, temp_path)

        FileUtils.mv temp_path, local_path
      end

      duration = Time.now - start

      puts "[download] Done downloading. Took #{duration}"
    end
  end
end
