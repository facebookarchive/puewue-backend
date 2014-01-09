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

    analyzer = Power::Analyzer.new

    start = Time.now

    puts "[import] About to analyze #{files.size} CSV files... (#{start})"

    Batch.each(files) do |filename|
      unless File.exists?(filename)
        raise RuntimeError, "Unable to find #{filename}, skipping."
        next
      end

      # file will be closed by Analyzer
      file = File.open(filename, "r")
      analyzer.analyze(file)
    end

    if analyzer.entries.any?
      puts "Collected #{analyzer.entries.size} entries to be imported."

      index = Tire.index "measurements"
      importer = Power::Importer.new(index)

      puts "Importing entries..."
      entries = analyzer.entries

      while entries.any?
        batch = entries.shift(200)

        importer.import batch

        print "."
        $stdout.flush
      end

      puts "\nImport completed."
    else
      puts "No entries found to be imported."
    end

    puts "Moving files into archive folder..."

    files.each do |filename|
      next unless File.exists?(filename)

      archive_file = File.join(File.dirname(filename), "archive", File.basename(filename))

      # ensure target directory exists
      FileUtils.mkdir_p File.dirname(archive_file)
      FileUtils.mv filename, archive_file
    end

    duration = Time.now - start

    puts "[import] Done. Took #{duration}"
  end
end
