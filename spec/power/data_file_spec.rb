require "spec_helper"
require "power/data_file"

describe Power::DataFile do
  let(:data) { Power::DataFile.new }

  before :each do
    Ohm.redis.flushdb
  end

  describe "requirements" do
    it "requires a filename" do
      data.filename = nil
      data.valid?
      data.errors[:filename].wont_be_empty
    end
  end

  describe "#process!" do
    let(:data) { Power::DataFile.create(:filename => "foo.csv") }

    it "changes the state to processing" do
      data.fresh?.must_equal true
      data.process!
      data.fresh?.must_equal false
      data.processing?.must_equal true
    end
  end

  describe "#complete!" do
    describe "(state)" do
      let(:data) { Power::DataFile.create(:filename => "bar.csv") }

      before :each do
        data.process!
      end

      it "changes the state to completed" do
        data.processing?.must_equal true
        data.complete!
        data.processing?.must_equal false
        data.completed?.must_equal true
      end
    end

    describe "(blob)" do
      let(:data) { Power::DataFile.create(:filename => "baz.csv", :blob => "something") }

      before :each do
        data.process!
      end

      it "removes the blob of information" do
        data.blob.must_equal "something"
        data.complete!
        data.blob.must_be_nil
      end
    end
  end

  describe "#contents" do
    context "given no blob content" do
      let(:data) { Power::DataFile.new(:blob => nil) }

      it "returns an empty IO object" do
        data.contents.must_be_kind_of StringIO
        data.contents.size.must_equal 0
      end
    end

    context "given something as blob" do
      let(:data) { Power::DataFile.new(:filename => "xyz.csv", :blob => "something") }

      it "returns the contents wrapped as IO object" do
        data.contents.must_be_kind_of StringIO
        data.contents.read.must_equal "something"
      end

      it "returns the filename as the 'path' of the object" do
        data.contents.path.wont_be_nil
        data.contents.path.must_equal "xyz.csv"
      end
    end
  end

  describe ".imported?" do
    context "given no imported file" do
      it "returns false" do
        result = Power::DataFile.imported?("nonexisting.csv")
        result.must_equal false
      end
    end

    context "given already imported file" do
      let(:filename) { "existing.csv" }

      before :each do
        Power::DataFile.create(:filename => filename)
      end

      it "returns true when requested same filename" do
        result = Power::DataFile.imported?(filename)
        result.must_equal true
      end
    end
  end
end
