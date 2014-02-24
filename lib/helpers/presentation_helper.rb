#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

module PresentationHelper
  def decimal(value)
    "%.2f" % value
  end

  def paragraph(text)
    return unless text

    text.gsub("\n", " ").strip
  end

  def page_title(title = nil)
    [title, "Power Dashboard"].compact.join(" - ")
  end
end
