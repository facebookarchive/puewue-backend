require "sinatra/base"
require "sinatra/get_or_post"
require "i18n"

require "helpers/assets_helper"
require "helpers/json_helper"
require "helpers/lookup_helper"
require "helpers/presentation_helper"

require "power/datacenter"
require "tire"
require "redis"

module Power
  class Application < Sinatra::Base
    extend Sinatra::GetOrPost

    set :root, File.expand_path("../..", __FILE__)
    set :sprockets, Sprockets::Environment.new

    configure do
      AssetsHelper.configure! sprockets, root

      # Load all i18n files (locales/*.yml)
      I18n.load_path.concat Dir[File.join(settings.root, "locales", "*.yml")]

      # disable frame protection
      set :protection, except: [:frame_options]

      # setup defaults
      set :center_lookup, Power::Datacenter
      set :cache_provider, Redis.new
      set :index_name, "measurements"

      Datacenter.from_file("config/datacenters.yml")
    end

    configure :staging do
      use Rack::Auth::Basic, "Power!" do |username, password|
        username == "power" && password == "allgreen"
      end
    end

    configure :staging, :production do
      require "rack/ssl"
      use Rack::SSL
    end

    helpers do
      include AssetsHelper
      include JsonHelper
      include LookupHelper
      include PresentationHelper
    end

    get_or_post "/faq" do
      erb :faq, :layout => false
    end

    get "/timeline/:datacenter_slug/:period.json" do
      datacenter = datacenter_by_slug(params[:datacenter_slug])

      halt(404) unless datacenter

      json timeline_for(datacenter, params[:period]).cached_json
    end

    get_or_post "/:datacenter_slug" do
      datacenter = datacenter_by_slug(params[:datacenter_slug])

      halt(404) unless datacenter

      erb :index, :locals => { :datacenter => datacenter }
    end

    get_or_post "/" do
      redirect to("/#{first_datacenter.slug}")
    end
  end
end
