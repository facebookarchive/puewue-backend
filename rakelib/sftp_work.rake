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

    puts "[work] Checking pending Data files... (#{start})"

    data_files = Power::DataFile.pending

    if data_files.size > 0
      analyzer  = Power::Analyzer.new
      filenames = []

      puts "About to analyze #{data_files.size} CSV files..."

      Batch.each(data_files) do |data_file|
        filenames.push data_file.filename

        # mark as being processed
        data_file.process!

        # analyze the entries
        analyzer.analyze(data_file.contents)
      end

      if analyzer.entries.any?
        puts "Collected #{analyzer.entries.size} entries to be imported."

        index = Tire.index "measurements"
        importer = Power::Importer.new(index)

        puts "Importing entries..."
        importer.import analyzer.entries
        puts "Import completed."
      else
        puts "No entries found to be imported."
      end

      # FIXME: Marking files shouldn't happen during analyze stage?
      puts "Marking pending data files as imported..."

      Power::DataFile.in_process.each do |data_file|
        next unless filenames.include?(data_file.filename)

        data_file.complete!
      end
    end

    duration = Time.now - start

    puts "[work] Done. Took #{duration}"
  end
end
