require "active_support/core_ext/object/blank"
require "multi_json"

module Power
  class Analyzer
    class Entry
      attr_accessor :datacenter, :points, :timestamp

      def initialize(datacenter, points)
        @datacenter = datacenter
        @points     = points
        @timestamp  = points.timestamp
      end

      def id
        @id ||= "%d-%d" % [datacenter.id, timestamp.to_i]
      end

      def to_hash
        {
          :id            => id,
          :datacenter_id => datacenter.id,
          :timestamp     => timestamp,
          :pue           => points.pue,
          :wue           => points.wue,
          :temperature   => points.temperature,
          :humidity      => points.humidity,
          :util_kwh      => points.util_kwh,
          :it_kwh        => points.it_kwh,
          :twu           => points.twu
        }.reject { |k, v| v.blank? }
      end

      def to_indexed_json
        MultiJson.dump(to_hash)
      end
    end
  end
end
