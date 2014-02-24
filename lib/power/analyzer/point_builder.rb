#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "tzinfo"

module Power
  class Analyzer
    class PointBuilder
      ROUND_PRECISION = 3

      PointsWrapper = Struct.new(:timestamp, :pue, :wue, :temperature,
                                  :humidity, :util_kwh, :it_kwh, :twu)

      TIMESTAMP_LABEL = "Timestamp".freeze
      PUE_LABEL       = "PUE".freeze
      WUE_LABEL       = "WUE".freeze
      TEMP_LABEL      = "Temp".freeze
      HUMIDITY_LABEL  = "humidity".freeze
      UTILKWH_LABEL   = "UtilKWh".freeze
      ITKWH_LABEL     = "ITKWh".freeze
      TWU_LABEL       = "TotaWaterUsage".freeze

      attr_reader :names

      def initialize(names)
        @names = Array(names)
      end

      def build(values)
        PointsWrapper.new.tap do |points|
          points.timestamp   = parse_timestamp(values)

          points.pue         = parse_decimal(values, PUE_LABEL)
          points.wue         = parse_decimal(values, WUE_LABEL)
          points.temperature = parse_decimal(values, TEMP_LABEL)
          points.humidity    = parse_decimal(values, HUMIDITY_LABEL)
          points.util_kwh    = parse_decimal(values, UTILKWH_LABEL)
          points.it_kwh      = parse_decimal(values, ITKWH_LABEL)
          points.twu         = parse_decimal(values, TWU_LABEL)
        end
      end

      private

      def parse_decimal(values, label)
        value = retrieve(values, label)

        value and
          Float(value).round(ROUND_PRECISION)
      end

      def parse_timestamp(values)
        if value = retrieve(values, TIMESTAMP_LABEL)
          timestamp = Time.parse(value)
          utc_timezone.local_to_utc(timestamp)
        end
      end

      def retrieve(values, label)
        index = names.index { |n| n == label }
        index and values[index]
      end

      def utc_timezone
        @utc_timezone ||= TZInfo::Timezone.get("UTC")
      end
    end
  end
end
