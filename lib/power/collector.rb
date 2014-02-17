module Power
  class Collector
    ROUND_PRECISION = 3
    CACHE_VERSION   = "v7"

    attr_accessor :index, :datacenter_id, :interval, :range

    def initialize(index, datacenter_id, interval, range)
      @index         = index
      @datacenter_id = datacenter_id
      @interval      = interval
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
      keys     = facet_keys
      base_key = keys.first

      result = {
        :timestamp => facet_entry(base_key, index)["time"],
      }

      ["temperature", "humidity"].each do |key|
        collect_values(key, index, result)
      end

      util_kwh_entry = facet_entry("util_kwh", index)
      it_kwh_a_entry = facet_entry("it_kwh_a", index)
      it_kwh_b_entry = facet_entry("it_kwh_b", index)
      twu_entry      = facet_entry("twu", index)

      computed_pue_entry = facet_entry("computed_pue", index)
      computed_wue_entry = facet_entry("computed_wue", index)

      pue              = calculate(util_kwh_entry, it_kwh_a_entry)
      min_pue, max_pue = calculate_min_max(computed_pue_entry)

      result[:pue] = pue ? pue : nil

      if min_pue && max_pue
        result[:min_pue] = min_pue
        result[:max_pue] = max_pue
      end

      wue              = calculate(twu_entry, it_kwh_b_entry)
      min_wue, max_wue = calculate_min_max(computed_wue_entry)

      result[:wue] = wue ? wue : nil

      if min_wue && max_wue
        result[:min_wue] = min_wue
        result[:max_wue] = max_wue
      end

      result
    end

    def facet_entry(key, index)
      query_results.facets[key]["entries"][index]
    end

    def build_query
      return @build_query if defined?(@build_query)

      index.query do |q|
        q.filtered do |f|
          f.query { all }

          f.filter :term, :datacenter_id => datacenter_id

          f.filter :range, :timestamp => {
                            :from => range.begin, :to => range.end
          }
        end
      end

      point_names.each do |point|
        index.facet point do |facet|
          facet.date :timestamp, :value_field => point, :interval => interval
        end
      end

      @build_query = index
    end

    def collect_values(key, index, result)
      entry = facet_entry(key, index)

      if entry && Integer(entry["total_count"]) > 0
        mean  = entry["mean"]
        min   = entry["min"]
        max   = entry["max"]

        result[key.to_sym] = Float(mean).round(ROUND_PRECISION)

        # min_:key and max_:key
        result[:"min_#{key}"] = Float(min).round(ROUND_PRECISION)
        result[:"max_#{key}"] = Float(max).round(ROUND_PRECISION)
      else
        result[key.to_sym] = nil
      end
    end

    def point_names
      @point_names ||= ["temperature", "humidity", "util_kwh",
                        "it_kwh_a", "it_kwh_b", "twu",
                        "computed_pue", "computed_wue"]
    end

    def calculate(num_entry, den_entry)
      return unless [num_entry, den_entry].all? { |e|
        e && e["total_count"] > 0
      }

      numerator   = Float(num_entry["total"])
      denominator = Float(den_entry["total"])

      # SUM(numerator) / SUM(denominator)
      (numerator / denominator).round(ROUND_PRECISION)
    end

    def calculate_min_max(computed_entry)
      return unless computed_entry && computed_entry["total_count"] > 0

      minimum = maximum = nil

      minimum = Float(computed_entry["min"]).round(ROUND_PRECISION)
      maximum = Float(computed_entry["max"]).round(ROUND_PRECISION)

      [minimum, maximum]
    end
  end
end
