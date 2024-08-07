module Darts
  extend self

  def score(x : Number, y : Number) : Number
    value = x ** 2 + y ** 2
    hypot = Math.hypot(x, y)
    if hypot <= 1
      10
    elsif hypot <= 5
      5
    elsif hypot <= 10
      1
    else
      0
    end
  end
end
