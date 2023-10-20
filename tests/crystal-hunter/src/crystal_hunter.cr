class Rules
  def bonus_points?(power_up_active, touching_bandit)
    power_up_active == true && touching_bandit == true
  end

  def score?(touching_power_up, touching_crystal)
    touching_power_up == true || touching_crystal == true
  end

  def lose?(power_up_active, touching_bandit)
    power_up_active == false && touching_bandit == true
  end

  def win?(has_picked_up_all_crystals, power_up_active, touching_bandit)
    has_picked_up_all_crystals == true && !lose?(power_up_active, touching_bandit)
  end
end
