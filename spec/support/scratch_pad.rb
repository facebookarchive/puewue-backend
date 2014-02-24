#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

class ScratchPad
  attr_reader :recorded

  def initialize(responses = {})
    @recorded = []

    responses.each do |m, value|
      define_singleton_method(m) {
        record m
        value
      }
    end
  end

  private

  def method_missing(method, *args)
    record method

    self
  end

  def record(method)
    recorded.push method.to_sym
  end
end
