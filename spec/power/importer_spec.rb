require "spec_helper"
require "power/importer"
require "support/scratch_pad"

describe Power::Importer do
  let(:importer) { Power::Importer.new(index) }

  describe "#import" do
    context "given a supplied index" do
      let(:index) { ScratchPad.new(:exists? => true) }

      it "stores entry information using bulk import" do
        importer.import(["entry"])
        index.recorded.must_include(:import)
      end
    end

    context "given no existing index" do
      let(:index) { ScratchPad.new(:exists? => false) }

      it "creates the index" do
        importer.import(["entry"])
        index.recorded.must_include(:create)
      end
    end
  end
end
