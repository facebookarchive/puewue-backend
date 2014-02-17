require "spec_helper"
require "power/analyzer/entry"
require "support/fake_points"

describe Power::Analyzer::Entry do
  include FakePoints

  let(:datacenter) { Power::Datacenter.add(99, "PRN", "Prineville") }
  let(:points)     { fake_points("1000") }
  let(:entry)      { Power::Analyzer::Entry.new(datacenter, points) }

  describe "#computed_pue" do
    context "with both 'util_kwh' and 'it_kwh' present" do
      let(:points) { extra_points(1.0, 2.0) }

      it "returns the calculated coeficient" do
        entry.computed_pue.must_equal 0.5
      end
    end

    context "without 'util_kwh' present" do
      let(:points) { extra_points(nil, 2.0) }

      it "returns nothing" do
        entry.computed_pue.must_be_nil
      end
    end

    context "without 'it_kwh' present" do
      let(:points) { extra_points(1.0, nil) }

      it "returns nothing" do
        entry.computed_pue.must_be_nil
      end
    end
  end

  describe "#computed_wue" do
    context "with both 'twu' and 'it_kwh' present" do
      let(:points) { extra_points(nil, 5.0, 1.0) }

      it "returns the calculated coeficient" do
        entry.computed_wue.must_equal 0.2
      end
    end

    context "without 'twu' present" do
      let(:points) { extra_points(nil, 2.0, nil) }

      it "returns nothing" do
        entry.computed_wue.must_be_nil
      end
    end

    context "without 'it_kwh' present" do
      let(:points) { extra_points(nil, nil, 1.0) }

      it "returns nothing" do
        entry.computed_wue.must_be_nil
      end
    end
  end

  describe "#id" do
    it "uses datacenter identification as part of the ID" do
      entry.id.must_include "99"
    end

    it "uses timestamp as part of the ID" do
      entry.id.must_include "1000"
    end
  end

  describe "#util_kwh" do
    context "with 'it_kwh' pair present" do
      let(:points) { extra_points(100.0, 100) }

      it "returns the provided value" do
        entry.util_kwh.must_equal 100.0
      end
    end

    context "without 'it_kwh' pair present" do
      let(:points) { extra_points(100.0) }

      it "returns nothing" do
        entry.util_kwh.must_be_nil
      end
    end
  end

  describe "#twu" do
    context "with 'it_kwh' pair present" do
      let(:points) { extra_points(nil, 100, 300) }

      it "returns the provided value" do
        entry.twu.must_equal 300
      end
    end

    context "without 'it_kwh' pair present" do
      let(:points) { extra_points(nil, nil, 300) }

      it "returns nothing" do
        entry.twu.must_be_nil
      end
    end
  end

  describe "#it_kwh_a" do
    context "with 'util_kwh' pair present" do
      let(:points) { extra_points(100, 500) }

      it "returns the provided value" do
        entry.it_kwh_a.must_equal 500
      end
    end

    context "without 'util_kwh' pair present" do
      let(:points) { extra_points(nil, 500) }

      it "returns nothing" do
        entry.it_kwh_a.must_be_nil
      end
    end
  end

  describe "#it_kwh_b" do
    context "with 'twu' pair present" do
      let(:points) { extra_points(nil, 500, 100) }

      it "returns the provided value" do
        entry.it_kwh_b.must_equal 500
      end
    end

    context "without 'twu' pair present" do
      let(:points) { extra_points(nil, 500) }

      it "returns nothing" do
        entry.it_kwh_b.must_be_nil
      end
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

    describe "given missing points" do
      let(:points) {
        fake_points("1000", 1.08, 0.88, 45)
      }

      it "includes only the present ones" do
        to_hash.must_include :pue
        to_hash.must_include :wue
        to_hash.must_include :temperature

        to_hash.wont_include :humidity
      end
    end

    describe "given denormalized missing points" do
      context "for PUE" do
        let(:points) { extra_points(100, 200) }

        it "includes matching pairs" do
          to_hash.must_include :util_kwh
          to_hash.must_include :it_kwh_a
        end

        it "includes computed_pue" do
          to_hash.must_include :computed_pue
        end

        it "does not include missing pairs" do
          to_hash.wont_include :twu
          to_hash.wont_include :it_kwh_b
        end
      end

      context "for WUE" do
        let(:points) { extra_points(nil, 200, 500) }

        it "includes matching pairs" do
          to_hash.must_include :twu
          to_hash.must_include :it_kwh_b
        end

        it "includes computed_wue" do
          to_hash.must_include :computed_wue
        end

        it "does not include missing pairs" do
          to_hash.wont_include :util_kwh
          to_hash.wont_include :it_kwh_a
        end
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
