require "multi_json"

module JsonHelper
  def json(object)
    pretty = settings.environment == "development"

    content_type "application/json"

    if object.is_a?(String)
      object
    else
      MultiJson.dump(object, :pretty => pretty)
    end
  end
end
