#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "spec_helper"
require "power/analyzer/point_builder"

describe Power::Analyzer::PointBuilder do
  let(:builder) { Power::Analyzer::PointBuilder.new(names).build(values) }

  describe "#build" do
    context "given 'Timestamp' with value" do
      let(:names)  { ["Timestamp"] }
      let(:values) { ["2012-12-25 03:46:00.000"] }

      it "identifies it as timestamp" do
        builder.timestamp.must_be_instance_of Time
      end
    end

    context "given no 'Timestamp'" do
      let(:names)  { [] }
      let(:values) { [] }

      it "returns nothing for timestamp" do
        builder.timestamp.must_be_nil
      end
    end

    context "given 'PUE' with value" do
      let(:names)  { ["PUE"] }
      let(:values) { ["1.0800001"] }

      it "identifies as pue" do
        builder.pue.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.pue.must_equal 1.080
      end
    end

    context "given 'WUE' with value" do
      let(:names)  { ["WUE"] }
      let(:values) { ["0.477504"] }

      it "identifies as wue" do
        builder.wue.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.wue.must_equal 0.478
      end
    end

    context "given 'Temp' with value" do
      let(:names)  { ["Temp"] }
      let(:values) { ["29.6100"] }

      it "identifies as temperature" do
        builder.temperature.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.temperature.must_equal 29.610
      end
    end

    context "given 'humidity' with value" do
      let(:names)  { ["humidity"] }
      let(:values) { ["76.884"] }

      it "identifies as humidity" do
        builder.humidity.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.humidity.must_equal 76.884
      end
    end

    context "given 'UtilKWh' with value" do
      let(:names)  { ["UtilKWh"] }
      let(:values) { ["297.566"] }

      it "identifies as util_kwh" do
        builder.util_kwh.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.util_kwh.must_equal 297.566
      end
    end

    context "given 'ITKWh' with value" do
      let(:names)  { ["ITKWh"] }
      let(:values) { ["275.166"] }

      it "identifies as it_kwh" do
        builder.it_kwh.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.it_kwh.must_equal 275.166
      end
    end

    context "given 'TotaWaterUsage' with value" do
      let(:names)  { ["TotaWaterUsage"] }
      let(:values) { ["0.145"] }

      it "identifies as twu" do
        builder.twu.wont_be_nil
      end

      it "cuts decimal resolution to three digits" do
        builder.twu.must_equal 0.145
      end
    end
  end
end
