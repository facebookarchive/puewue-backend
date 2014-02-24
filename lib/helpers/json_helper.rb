#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

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
