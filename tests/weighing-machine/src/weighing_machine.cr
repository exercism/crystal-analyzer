class WeighingMachine
  def precision : Int32
    @precision
  end

  def metric=(value : Bool) : Bool
    @metric = value
  end

  def weight : Float64
    @weight
  end

  def weight=(value : Float64) : Float64
    @weight = value
  end
  
  def initialize(precision : Int32, metric : Bool = true)
    @precision = precision
    @metric = metric
  end

  # DO NOT MODIFY ANYTHING BELOW THIS LINE
  def weigh : String
    weight = @metric ? @weight : @weight * 2.20462
    weight = weight.round(@precision)
    weight.to_s
  end
end
