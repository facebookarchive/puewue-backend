require "spec_helper"
require "power/analyzer/entry"
require "power/analyzer/point_builder"

describe Power::Analyzer::Entry do
  let(:datacenter) { Power::Datacenter.add(99, "PRN", "Prineville") }
  let(:points)     { Power::Analyzer::PointBuilder::PointsWrapper.new("1000") }
  let(:entry)      { Power::Analyzer::Entry.new(datacenter, points) }

  describe "#id" do
    it "uses datacenter identification as part of the ID" do
      entry.id.must_include "99"
    end

    it "uses timestamp as part of the ID" do
      entry.id.must_include "1000"
    end
  end

  describe "#to_hash" do
    let(:to_hash) { entry.to_hash }

    it "includes the id" do
      to_hash.must_include :id
    end

    it "includes the datacenter ID" do
      to_hash.must_include :datacenter_id
    end

    context "given missing points" do
      let(:points) {
        Power::Analyzer::PointBuilder::PointsWrapper.new("1000", 1.08, 0.88,
                                                          45, 25)
      }

      it "includes only the present ones" do
        to_hash.must_include :pue
        to_hash.must_include :wue
        to_hash.must_include :temperature
        to_hash.must_include :humidity

        to_hash.wont_include :util_kwh
        to_hash.wont_include :it_kwh
      end
    end
  end

  describe "#to_indexed_json" do
    let(:to_indexed_json) { entry.to_indexed_json }

    it "serializes the attributes" do
      to_indexed_json.must_be_instance_of String
      to_indexed_json.must_include "timestamp"
      to_indexed_json.must_include "1000"
    end
  end
end
