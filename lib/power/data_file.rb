#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "ohm"
require "ohm/timestamps"
require "ohm/callbacks"
require "micromachine"
require "stringio"

module Power
  class DataFile < Ohm::Model
    class Blob < StringIO
      attr_accessor :path
    end

    include Ohm::Timestamps
    include Ohm::Callbacks

    # possible states
    FRESH      = 0
    PROCESSING = 1
    IMPORTED   = 2

    attribute :blob
    attribute :filename
    attribute :state_id

    unique :filename
    index  :state_id

    def self.pending
      find(:state_id => FRESH)
    end

    def self.in_process
      find(:state_id => PROCESSING)
    end

    def self.completed
      find(:state_id => IMPORTED)
    end

    def self.imported?(filename)
      with(:filename, filename) ? true : false
    end

    def complete!
      state.trigger(:complete)
      save
    end

    def completed?
      state.state == IMPORTED
    end

    def contents
      return @contents if defined?(@contents)

      @contents = Blob.new(blob || "")
      @contents.path = filename

      @contents
    end

    def fresh?
      state.state == FRESH
    end

    def process!
      state.trigger(:process)
      save
    end

    def processing?
      state.state == PROCESSING
    end

    private

    def before_create
      self.state_id = FRESH
    end

    def state
      return @state if defined?(@state)

      @state = MicroMachine.new Integer(state_id || FRESH)

      @state.when(:process, FRESH => PROCESSING)
      @state.when(:complete, PROCESSING => IMPORTED)

      @state.on(:any) do
        self.state_id = state.state
      end

      @state.on(IMPORTED) do
        self.blob = nil
      end

      @state
    end

    def validate
      assert_present :filename
    end
  end
end
