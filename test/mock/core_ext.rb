class String
  alias blank? empty?
end

class NilClass
  def blank?
    true
  end
end
