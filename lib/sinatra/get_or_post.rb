module Sinatra
  module GetOrPost
    def get_or_post(url, &block)
      get  url, &block
      post url, &block
    end
  end
end
