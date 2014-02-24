#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "spec_helper"
require "power/analyzer"

require "support/fake_builder"
require "support/fake_file"
require "support/csv_fixtures"

describe Power::Analyzer do
  include CSVFixtures

  describe "#analyze" do
    let(:analyzer) { Power::Analyzer.new }
    let(:file) {
      FakeFile.new("csv/fake.csv", one_entry)
    }

    context "given no entries in CSV" do
      let(:file) { FakeFile.new("csv/foo.csv", "") }

      it "returns an empty list of entries" do
        analyzer.analyze(file)
        analyzer.entries.must_be_empty
      end
    end

    context "given single entry in CSV" do
      it "returns one entry" do
        analyzer.analyze(file)
        analyzer.entries.size.must_equal 1
      end
    end

    context "given a datacenter in the records" do
      let(:center_lookup) { MiniTest::Mock.new }
      let(:file)            {
        FakeFile.new("csv/FRC_2013-03-14_16:30:05.732412356-07:00.csv", one_entry)
      }

      before :each do
        analyzer.center_lookup = center_lookup
      end

      it "lookups for datacenter by short_name" do
        center_lookup.expect(:by_short_name, "datacenter", ["FRC"])
        analyzer.analyze(file)
        center_lookup.verify
      end
    end

    context "dealing with entry points" do
      let(:builder)       { Power::Analyzer::PointBuilder.new([]) }
      let(:point_builder) { MiniTest::Mock.new }

      before :each do
        analyzer.point_builder = point_builder
      end

      it "constructs a point builder with point names" do
        point_builder.expect(:new, builder,
              [["Timestamp", "PUE", "WUE", "Temp", "humidity", "UtilKWh", "ITKWh", "TotaWaterUsage"]])

        analyzer.analyze(file)
        point_builder.verify
      end
    end

    context "dealing with entry processing" do
      let(:point_builder) { FakeBuilder }
      let(:entry_builder) { MiniTest::Mock.new }
      let(:file) {
        FakeFile.new("csv/fake.csv", one_entry)
      }

      before :each do
        analyzer.point_builder = point_builder
        analyzer.entry_builder = entry_builder
      end

      it "builds an entry with data from CSV" do
        entry_builder.expect(:new, "entry",
                              [nil, "points"])

        analyzer.analyze(file)
        entry_builder.verify
      end
    end

    context "given an entry without data" do
      let(:file) {
        FakeFile.new("csv/missing.csv", entry_missing)
      }

      it "builds the entry" do
        analyzer.analyze(file)
        analyzer.entries.wont_be_empty
      end
    end
  end
end
