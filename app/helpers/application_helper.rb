module ApplicationHelper
  def u8(s)
    return s if s.nil?
    return s.force_encoding('UTF-8')
  end
end
