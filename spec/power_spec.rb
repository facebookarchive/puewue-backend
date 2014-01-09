require "spec_helper"
require "power"

describe Power::Application do
  include Rack::Test::Methods

  let(:app) { Power::Application }

  describe "/" do
    before :each do
      Power::Datacenter.clear!
      Power::Datacenter.add 1, "PRN", "prineville"
    end

    it "redirects to first datacenter" do
      get "/"
      last_response.status.must_equal 302
      last_response.location.must_equal "http://example.org/prineville"
    end
  end

  describe "/:datacenter_slug" do
    let(:datacenter)    { Power::Datacenter.new(1, "PRN", "prineville") }
    let(:center_lookup) { MiniTest::Mock.new }

    before :each do
      app.settings.set :center_lookup, center_lookup
    end

    it "lookups for datacenter first" do
      center_lookup.expect(:by_slug, datacenter, ["prineville"])
      get "/prineville"
      center_lookup.verify
    end

    it "returns 404 if datacenter does not exist" do
      center_lookup.expect(:by_slug, nil, ["foo"])
      get "/foo"
      center_lookup.verify
      last_response.status.must_equal 404
    end
  end
end
