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
