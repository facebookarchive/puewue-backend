require "csv"
require "power/datacenter"
require "power/analyzer/entry"
require "power/analyzer/point_builder"

module Power
  # Public: Analyze the contents of supplied CSV files and return a list of
  # processed entries
  class Analyzer
    POINT_NAME  = /^Point\_\d+/
    START_TABLE = "<>Date"
    END_TABLE   = "End of Report"
    NO_DATA     = "No Data"

    attr_reader :entries
    attr_accessor :center_lookup, :point_builder, :entry_builder

    def initialize
      @entries         = []

      # default providers
      @center_lookup  = Power::Datacenter
      @point_builder  = Power::Analyzer::PointBuilder
      @entry_builder  = Power::Analyzer::Entry
    end

    def analyze(file_or_io)
      csv = CSV.new(file_or_io)

      datacenter = identify_datacenter(csv)

      builder = find_points(csv)

      # extrac useful entries
      extract_entries(datacenter, builder, csv)

      csv.close
    end

    private

    def identify_datacenter(csv)
      short_name = File.basename(csv.path).split("_").first
      center_lookup.by_short_name(short_name)
    end

    # Extract points names and pass to point_builder
    # first line of CSV file is the header with the names
    def find_points(csv)
      names = csv.readline

      point_builder.new(names)
    end

    def extract_entries(datacenter, builder, csv)
      csv.each do |values|
        points = builder.build(values)
        entry = entry_builder.new(datacenter, points)

        entries.push entry
      end
    end
  end
end
