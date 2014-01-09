namespace :sftp do
  desc "Archive remote CSV files SFTP into archive directory (default: csv)"
  task :archive, [:target] => :environment do |t, args|
    args.with_defaults(:target => "csv")

    require "net/sftp"
    require "batch"

    # ensure target exists
    target = args.target
    archive = File.join(target, "archive")

    FileUtils.mkdir_p target
    FileUtils.mkdir_p archive

    host, user, directory, key_path = ENV.values_at("SFTP_HOST", "SFTP_USER",
                                                    "SFTP_DIR", "SFTP_KEY")

    unless [host, user, directory, key_path].all?
      abort "SFTP_HOST, SFTP_USER and SFTP_DIR and SFTP_KEY are required."
    end

    # read key file
    key_data = File.read(key_path)

    Net::SFTP.start(host, user, :key_data => key_data) do |sftp|
      puts "Collecting CSV files from '#{directory}'..."

      # retrieve all the files in the directory
      entries = sftp.dir.glob(directory, "*.csv")

      if entries.empty?
        puts "Nothing found, exiting."
        break
      end

      # determine existing files (that we already have)
      existing_entries = entries.select { |entry|
        target_file  = File.join(target, entry.name)
        archive_file = File.join(archive, entry.name)

        File.exist?(target_file) || File.exist?(archive_file)
      }

      puts "Found #{entries.size} CSV files, about to move #{existing_entries.size} into archive..."

      Batch.each(existing_entries) do |entry|
        # build remote filename
        remote_path = File.join(directory, entry.name)
        archive_path = File.join(directory, "archive", entry.name)

        # move file around
        sftp.rename!(remote_path, archive_path)
      end

      puts "Done archiving."
    end
  end
end
