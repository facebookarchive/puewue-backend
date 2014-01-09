require "spec_helper"
require "power/datacenter"

describe Power::Datacenter do
  before :each do
    Power::Datacenter.clear!
  end

  describe "#add" do
    it "returns an entry" do
      entry = Power::Datacenter.add(1, "PRN", "prineville")

      entry.must_be_instance_of Power::Datacenter
      entry.id.must_equal 1
      entry.short_name.must_equal "PRN"
      entry.slug.must_equal "prineville"
    end

    it "accepts optional timezone name" do
      entry = Power::Datacenter.add(1, "PRN", "prineville", "America/Los_Angeles")

      entry.must_be_instance_of Power::Datacenter
      entry.zone_name.must_equal "America/Los_Angeles"
    end
  end

  describe "#by_id" do
    context "given no existing entries" do
      it "returns nothing" do
        entry = Power::Datacenter.by_id(99)
        entry.must_be_nil
      end
    end

    context "given an existing entry" do
      before :each do
        Power::Datacenter.add 1, "PRN", "prineville"
      end

      it "returns the requested entry" do
        entry = Power::Datacenter.by_id(1)
        entry.must_be_instance_of Power::Datacenter
        entry.id.must_equal 1
      end
    end
  end

  describe "#by_short_name" do
    context "given no existing entry" do
      it "returns nothing" do
        entry = Power::Datacenter.by_short_name("missing")
        entry.must_be_nil
      end
    end

    context "given many entries exists" do
      before :each do
        Power::Datacenter.add 1, "PRN", "prineville"
        Power::Datacenter.add 2, "FRC", "forest-city"
      end

      it "returns the requested entry" do
        entry = Power::Datacenter.by_short_name("FRC")
        entry.id.must_equal 2
      end
    end
  end

  describe "#by_slug" do
    context "given no existing entry" do
      it "returns nothing" do
        entry = Power::Datacenter.by_slug("missing")
        entry.must_be_nil
      end
    end

    context "given many entries exists" do
      before :each do
        Power::Datacenter.add 1, "PRN", "prineville"
        Power::Datacenter.add 2, "FRC", "forest-city"
      end

      it "returns the requested entry" do
        entry = Power::Datacenter.by_slug("forest-city")
        entry.id.must_equal 2
      end
    end
  end

  describe "#all" do
    context "given no entries" do
      it "returns an empty array" do
        entries = Power::Datacenter.all
        entries.must_be_instance_of Array
        entries.must_be_empty
      end
    end

    context "given one entry" do
      it "returns that entry" do
        entry = Power::Datacenter.add 1, "FOO", "foo"

        entries = Power::Datacenter.all
        entries.first.must_equal entry
      end
    end
  end

  describe "#first" do
    context "given no entries" do
      it "returns nothing" do
        entry = Power::Datacenter.first
        entry.must_be_nil
      end
    end

    context "given multiple entries" do
      before :each do
        Power::Datacenter.add 1, "PRN", "prineville"
        Power::Datacenter.add 2, "FRC", "forest-city"
      end

      it "returns the first one" do
        entry = Power::Datacenter.first
        entry.must_be_instance_of Power::Datacenter
        entry.id.must_equal 1
      end
    end
  end

  describe "#clear!" do
    context "given existing entries" do
      before :each do
        Power::Datacenter.add 99, "FOO", "foo"
      end

      it "removes those entries" do
        Power::Datacenter.clear!

        entry = Power::Datacenter.by_id(99)
        entry.must_be_nil
      end
    end
  end

  describe "#from_file" do
    before :each do
      Power::Datacenter.from_file(config_file)
    end

    context "given a single entry file" do
      let(:config_file) { File.expand_path("../../fixtures/1_center.yml", __FILE__) }

      it "loads base values" do
        Power::Datacenter.all.size.must_equal 1

        entry = Power::Datacenter.by_id(1)
        entry.short_name.must_equal "PRN"
        entry.slug.must_equal "prineville"
        entry.display_name.must_equal "Prineville, OR"
        entry.zone_name.must_equal "America/Los_Angeles"
      end
    end
  end
end
