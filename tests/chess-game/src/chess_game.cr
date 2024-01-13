module Chess
  RANKS = 1..8
  FILES = 'A'..'H'

  def self.valid_square?(rank, file)
    1..8.includes?(rank) && 'A'..'H'.includes?(file)
  end

  def self.nickname(first_name, last_name)
    (first_name[...2] + last_name[-2..]).upcase
  end

  def self.move_message(first_name, last_name, square)
    if 1..8.includes?(square[1].to_i) && 'A'..'H'.includes?(square[0])
      "#{(first_name[...2] + last_name[-2..]).upcase} moved to #{square}"
    else
      "#{(first_name[...2] + last_name[-2..]).upcase} attempted to move to #{square}, but that is not a valid square"
    end
  end
end
