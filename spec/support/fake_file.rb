require "stringio"

class FakeFile < StringIO
  attr_reader :path

  def initialize(path, contents)
    super contents
    @path = path
  end
end
