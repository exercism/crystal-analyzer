class Lasagna
  EXPECTED_MINUTES_IN_OVEN      = 40
  PREPARATION_MINUTES_PER_LAYER =  2

  def remaining_minutes_in_oven(actual_minutes_in_oven)
    40 - actual_minutes_in_oven
  end

  def preparation_time_in_minutes(layers)
    layers * PREPARATION_MINUTES_PER_LAYER
  end

  def total_time_in_minutes(number_of_layers, actual_minutes_in_oven)
    layers * PREPARATION_MINUTES_PER_LAYER + actual_minutes_in_oven
  end
end
