require "multi_json"
require "power/collector"

module Power
  class Timeline
    attr_accessor :search_provider, :datacenter, :period
    attr_accessor :collector_provider, :cache_provider

    def initialize(search_provider, datacenter, period = nil, collector_provider = nil)
      @search_provider    = search_provider
      @datacenter         = datacenter
      @period             = period || "24-hours"
      @collector_provider = collector_provider || Power::Collector
    end

    def entries
      collector_entries
    end

    def cached_json
      return entries unless cache_provider

      data = cache_provider.get(collector.cache_key)
      unless data
        data = MultiJson.dump(entries)
        cache_provider.setex(collector.cache_key, 3600, data)
      end

      data
    end

    private

    def collector_entries
      @collector_entries ||= collector.entries
    end

    def collector
      interval, range = determine_period
      collector_provider.new(search_provider, datacenter.id, interval, range)
    end

    def determine_period
      case period
      when "24-hours"
        ["5m", days_back(24, 2.5)]
      when "7-days"
        ["1.25h", days_back(168)]
      when "30-days"
        ["5h", days_back(720)]
      when "90-days"
        ["15h", days_back(2160)]
      when "1-year"
        ["5d", days_back(8760)]
      end
    end

    def days_back(hours, hour_offset = 0)
      to   = (Time.now.utc) - (hour_offset * 3600)
      to   = to - to.sec

      from = to - (hours * 3600)

      from..to
    end
  end
end
