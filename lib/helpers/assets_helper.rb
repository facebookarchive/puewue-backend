require "sprockets"
require "sprockets-sass"
require "sass"

module AssetsHelper
  def asset_path(source)
    "/assets/" + settings.sprockets.find_asset(source).digest_path
  end

  def self.configure!(sprockets, root)
    ["images", "javascripts", "stylesheets", "bower_components"].each do |folder|
      sprockets.append_path File.join(root, "assets", folder)
    end

    sprockets.context_class.instance_eval do
      include AssetsHelper
    end
  end
end
