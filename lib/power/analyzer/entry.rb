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

      def computed_pue
        return unless [util_kwh, it_kwh_a].all?

        util_kwh / it_kwh_a
      end

      def computed_wue
        return unless [twu, it_kwh_b].all?

        twu / it_kwh_b
      end

      def id
        @id ||= "%d-%d" % [datacenter.id, timestamp.to_i]
      end

      def util_kwh
        return unless points.it_kwh

        points.util_kwh
      end

      def twu
        return unless points.it_kwh

        points.twu
      end

      def it_kwh_a
        return unless points.util_kwh

        points.it_kwh
      end

      def it_kwh_b
        return unless points.twu

        points.it_kwh
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
          :util_kwh      => util_kwh,
          :it_kwh_a      => it_kwh_a,
          :it_kwh_b      => it_kwh_b,
          :twu           => twu,
          :computed_pue  => computed_pue,
          :computed_wue  => computed_wue
        }.reject { |k, v| v.blank? }
      end

      def to_indexed_json
        MultiJson.dump(to_hash)
      end
    end
  end
end
