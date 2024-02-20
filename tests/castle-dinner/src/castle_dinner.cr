class CastleDinner
  def self.check_food?(food)
    food == "Mushroom pasties" ? food : nil
  end
  def self.check_drink?(drink)
    drink.downcase.includes?("i") ? drink : nil
  end
  def self.replace_drink(drink)
    drink.downcase.includes?("i") ? drink : "Apple juice"
  end
end
