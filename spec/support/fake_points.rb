#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "power/analyzer/point_builder"

module FakePoints
  def fake_points(*args)
    Power::Analyzer::PointBuilder::PointsWrapper.new(*args)
  end

  # util_kwh, it_kwh, twu
  def extra_points(util_kwh = nil, it_kwh = nil, twu = nil)
    fake_points("1000", 1.09, 1.10, 45, 25, util_kwh, it_kwh, twu)
  end
end
