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
