require "compiler/crystal/syntax"
require "./analyzer"
require "./visitor_analyzer"

class ExerciseAnayzer
  getter exercise, anlyzation
  property comments, concepts

  @comments = Array(Comments).new
  @anlyzation : Array(Types) = Array(Types).new
  @concepts : Array(String) = Array(String).new

  def initialize(exercise : String, path : String)
    file_content = File.read(path)
    begin
      solution = Crystal::Parser.new(file_content)
      ast = solution.parse
      analyser = GeneralAnalyzer.new
      analyser.accept(ast)
      @anlyzation = analyser.types
      @concepts = analyser.concepts # Adding the possibilty of marking an exercise as having a certain concept
    rescue
      p "Error parsing the file"
    end
    @exercise = exercise
  end

  def exercise_tags
    case exercise
    when "sieve"
      if anlyzation.any? { |x| (x.options["name"] == "%" || x.options["name"] == "/") && x.options["type"] == "Call" }
        @comments << Comments.new("crystal.sieve.do_not_use_div_rem", Hash(String, String | Int32).new, "essential")
      end
    when "two-fer"
      if anlyzation.none? do |x|
           unless x.argumments.empty?
             first_argumment = x.argumments[0]
             first_argumment["default_argument"]? == "\"you\"" && first_argumment["type"] == "Arg" && x.inside_method == "two_fer"
           else
             false
           end
         end
        @comments << Comments.new("crystal.two-fer.incorrect_default_param", Hash(String, String | Int32).new, "actionable")
      end
      if anlyzation.any? { |x| x.options["name"] == "+" && x.options["type"] == "Call" && x.inside_method == "two_fer" }
        @comments << Comments.new("crystal.two-fer.string_concatenation", Hash(String, String | Int32).new, "actionable")
      end
    when "arys-amazing-lasagna"
      if anlyzation.none? { |x| x.options["name"] == "preparation_time_in_minutes" && x.options["type"] == "Call" && x.inside_method == "total_time_in_minutes" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "Lasagna.total_time_in_minutes", "item_2" => "Lasagna.preparation_time_in_minutes"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "-" && x.options["receiver"]? == "EXPECTED_MINUTES_IN_OVEN" && x.options["type"] == "Call" && x.inside_method == "remaining_minutes_in_oven" }
        options = Hash(String, String | Int32){"concept" => "constant", "item_1" => "Lasagna.remaining_minutes_in_oven", "item_2" => "Lasagna::EXPECTED_MINUTES_IN_OVEN"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
    when "navigation-computer"
      if anlyzation.any? do |x|
           temp = x.options["value"]?
           unless temp.nil?
             {"NEPTUNE_DISTANCE", "MARS_DISTANCE", "ATMOSPHERE_DISTANCE"}.includes?(x.options["name"]) && x.options["type"] == "Assign" && temp.includes?("to_i")
           end
         end
        @comments << Comments.new("crystal.navigation-computer.to_i", Hash(String, String | Int32).new, "actionable")
      end
    when "crystal-hunter"
      if anlyzation.any? { |x| x.options["type"] == "Call" && x.options["name"] == "==" && x.argumments.any? { |x| x["name"] == "true" || x["name"] == "false" } }
        @comments << Comments.new("crystal.crystal-hunter.true_false", Hash(String, String | Int32).new, "actionable")
      end
    when "leap"
      if anlyzation.any? { |x| x.options["type"] == "If" }
        @comments << Comments.new("crystal.leap.do_not_use_if_statement", Hash(String, String | Int32).new, "actionable")
      end
      if anlyzation.any? { |x| x.options["type"] == "Call" && x.options["name"] == "%" }
        @comments << Comments.new("crystal.leap.modulo", Hash(String, String | Int32).new, "informative")
      end
    when "wellingtons-weather-station"
      if anlyzation.any? { |x| x.options["type"] == "If" && x.inside_method == "number_missing_sensors" }
        @comments << Comments.new("crystal.wellingtons-weather-station.do_not_use_if_statement", Hash(String, String | Int32).new, "actionable")
      end
    when "gigasecond"
      anlyzation.each do |x|
        if x.options["type"] == "Call" && x.options["name"] == "**"
          if temp = x.options["raw_value"]
            options = Hash(String, String | Int32){"value" => temp}
            @comments << Comments.new("crystal.gigasecond.pow", options, "informative")
            break
          end
        end
      end
    when "reverse-string"
      if anlyzation.any? { |x| x.options["type"] == "Call" && x.options["name"] == "reverse" }
        @comments << Comments.new("crystal.reverse-string.reverse", Hash(String, String | Int32).new, "celebratory")
      end
    when "chess-game"
      if anlyzation.none? { |x| x.options["name"] == "valid_square?" && x.options["type"] == "Call" && x.inside_method == "move_message" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "Chess.move_message", "item_2" => "Chess.valid_square?"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "nickname" && x.options["type"] == "Call" && x.inside_method == "move_message" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "Chess.move_message", "item_2" => "Chess.nickname"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "FILES" && x.options["type"] == "Call" && x.inside_method == "valid_square?" }
        options = Hash(String, String | Int32){"concept" => "constant", "item_1" => "Chess.valid_square?", "item_2" => "Chess::FILES"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "RANKS" && x.options["type"] == "Call" && x.inside_method == "valid_square?" }
        options = Hash(String, String | Int32){"concept" => "constant", "item_1" => "Chess.valid_square?", "item_2" => "Chess::RANKS"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
    when "password-lock"
      if anlyzation.none? { |x| x.options["name"] == "encrypt" && x.options["type"] == "Call" && x.inside_method == "unlock?" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "PasswordLock#unlock?", "item_2" => "PasswordLock#encrypt"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
    when "collatz-conjecture"
      if anlyzation.any? { |x| x.options["type"] == "Call" && x.options["name"] == "%" }
        @comments << Comments.new("crystal.collatz-conjecture.modulo", Hash(String, String | Int32).new, "informative")
      end
    when "library-of-luton"
      if anlyzation.none? { |x| x.options["name"] == "first_letter" && x.options["type"] == "Call" && x.inside_method == "initials" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "Library.initials", "item_2" => "Library.first_letter"}
        @comments << Comments.new("crystal.general.reuse", options, "informative")
      end
      if anlyzation.none? { |x| x.options["name"] == "decrypt_character" && x.options["type"] == "Call" && x.inside_method == "decrypt_text" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "Library.decrypt_text", "item_2" => "Library.decrypt_character"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
    when "castle-dinner"
      if anlyzation.none? { |x| x.options["name"] == "check_drink" && x.options["type"] == "Call" && x.inside_method == "replace_drink" }
        options = Hash(String, String | Int32){"concept" => "function", "item_1" => "CastleDinner.replace_drink", "item_2" => "CastleDinner.check_drink?"}
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "||" && x.options["type"] == "Call" && x.inside_method == "replace_drink" }
        @comments << Comments.new("crystal.castle-dinner.use_or", Hash(String, String | Int32).new, "actionable")
      else
        @comments << Comments.new("crystal.castle-dinner.uses_or", Hash(String, String | Int32).new, "celebratory")
      end
    end
  end
end
