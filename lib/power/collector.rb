module Power
  class Collector
    ROUND_PRECISION = 3
    POINT_NAMES     = ["pue", "wue", "humidity", "temperature"]
    CACHE_VERSION   = "v2"

    attr_accessor :index, :datacenter_id, :interval, :range

    def initialize(index, datacenter_id, interval = nil, range = nil)
      @index         = index
      @datacenter_id = datacenter_id
      @interval      = interval || "1m"
      @range         = range
    end

    def cache_key
      first = first_facet_entries.first["time"]
      last  = first_facet_entries.last["time"]

      "collector:#{CACHE_VERSION}:#{interval}:#{datacenter_id}:#{first}:#{last}"
    end

    def entries
      first_facet_entries.collect { |source_entry|
        index = first_facet_entries.index(source_entry)
        build_entry(index)
      }
    end

    private

    def first_facet_entries
      first_facet = facet_keys.first
      query_results.facets[first_facet]["entries"]
    end

    def facet_keys
      query_results.facets.keys
    end

    def query_results
      @query_results ||= build_query.perform.results
    end

    def build_entry(index)
      keys = facet_keys
      base_key = keys.first

      result = {
        :timestamp => facet_entry(base_key, index)["time"],
      }

      keys.each do |key|
        entry = facet_entry(key, index)

        # skip key entirely if there is nothing
        unless Integer(entry["total_count"]) > 0
          result[key.to_sym] = 0
          next
        end

        mean  = entry["mean"]
        min   = entry["min"]
        max   = entry["max"]

        result[key.to_sym] = Float(mean).round(ROUND_PRECISION)

        # min_:key and max_:key
        result[:"min_#{key}"] = Float(min).round(ROUND_PRECISION)
        result[:"max_#{key}"] = Float(max).round(ROUND_PRECISION)
      end

      result
    end

    def facet_entry(key, index)
      query_results.facets[key]["entries"][index]
    end

    # TODO: Complex as hell, refactor
    def build_query
      return @build_query if defined?(@build_query)

      index.query do |q|
        q.filtered do |f|
          f.query { all }

          f.filter :term, :datacenter_id => datacenter_id

          if range
            f.filter :range, :timestamp => {
                              :from => range.begin, :to => range.end
            }
          end
        end
      end

      POINT_NAMES.each do |point|
        index.facet point do |facet|
          facet.date :timestamp, :value_field => point, :interval => interval
        end
      end

      @build_query = index
    end

    def lucene(datetime)
      datetime.strftime("%Y-%m-%dT%H:%M:%S")
    end
  end
end
