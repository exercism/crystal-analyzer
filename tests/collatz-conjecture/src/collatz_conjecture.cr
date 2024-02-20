module CollatzConjecture
  def self.steps(input : Number) : Number
    raise ArgumentError.new if input < 1
    step = 0
    while input > 1
      if input % 2 == 0
        input = input / 2
      else
        input = (input * 3) + 1
      end
      step += 1
    end
    step
  end
end
