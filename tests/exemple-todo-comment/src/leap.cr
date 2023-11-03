class Temperature
  # TODO: comment
  def to_kelvin(clius)
    clius + 273.15
  end

  def round(clius)
    clius.round(1)
  end

  def to_fahrenheit(clius)
    ((clius * 1.8) + 32).to_i
  end

  def number_missing_sensors(number_of_sensorss)
    (4 - number_of_sensorss) % 4
  end
end
