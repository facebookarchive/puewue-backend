module PresentationHelper
  def decimal(value)
    "%.2f" % value
  end

  def paragraph(text)
    return unless text

    text.gsub("\n", " ").strip
  end

  def page_title(title = nil)
    [title, t("site.title")].compact.join(" - ")
  end

  def t(*args)
    I18n.t(*args)
  end
end
