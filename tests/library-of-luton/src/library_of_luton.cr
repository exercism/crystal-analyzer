class Library
  def self.first_letter(title : String) : Char
    title[0]
  end

  def self.initials(first_name : String, last_name : String) : String
    "#{first_name[0]}.#{last_name[0]}"
  end

  def self.decrypt_character(character : Char) : Char
    if character == 'A'
      'Z'
    elsif character == 'a'
      'z'
    else
      character.pred
    end
  end

  def self.decrypt_text(text : String) : String
    salida_chars = Array(Char).new
    text.each_char.each do |elt|
      if elt >= 'a' && elt <= 'z'
        if elt == 'A'
          'Z'
        elsif elt == 'a'
          'z'
        else
          salida_chars.push(elt.pred)
        end
      elsif elt >= 'A' && elt <= 'Z'
        if elt == 'A'
          'Z'
        elsif elt == 'a'
          'z'
        else
          salida_chars.push(elt.pred)
        end
      else
        salida_chars.push(elt)
      end
    end
    salida_chars.join("")
  end
end
