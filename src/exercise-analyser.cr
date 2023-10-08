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
        @comments << Comments.new("crystal.sieve.do_not_use_div", Hash(String, String | Int32).new, "essential")
      end
    when "two-fer"
      if anlyzation.none? { |x| x.options["name"] == "you" && x.options["type"] == "Arg" && x.inside_method == "two_fer" }
        @comments << Comments.new("crystal.two-fer.incorrect_default_param", Hash(String, String | Int32).new, "actionable")
      end
      if anlyzation.any? { |x| x.options["name"] == "+" && x.options["type"] == "Call" && x.inside_method == "two_fer" }
        @comments << Comments.new("rystal.two-fer.string_concatenation", Hash(String, String | Int32).new, "actionable")
      end
    when "arys-amazing-lasagna"
      if anlyzation.none? { |x| x.options["name"] == "preparation_time_in_minutes" && x.options["type"] == "Call" && x.inside_method == "total_time_in_minutes" }
        options = Hash(String, String | Int32).new
        options["concept"] = "function"
        options["item_1"] = "Lasagna.preparation_time_in_minutes"
        options["item_2"] = "Lasagna.total_time_in_minutes"
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
      if anlyzation.none? { |x| x.options["name"] == "EXPECTED_MINUTES_IN_OVEN" && x.options["name"] == "Assign" && x.inside_method == "remaining_minutes_in_oven" }
        options = Hash(String, String | Int32).new
        options["concept"] = "constant"
        options["item_1"] = "Lasagna.remaining_minutes_in_oven"
        options["item_2"] = "Lasagna::EXPECTED_MINUTES_IN_OVEN"
        @comments << Comments.new("crystal.general.reuse", options, "actionable")
      end
    when "navigation-computer"
      if anlyzation.any? do |x|
           temp = x.options["value"]
           unless temp.nil?
             {"NEPTUNE_DISTANCE", "MARS_DISTANCE", "ATMOSPHERE_DISTANCE"}.includes?(x.options["name"]) && x.options["type"] == "Assign" && temp.includes?("to_i")
           end
         end
        @comments << Comments.new("crystal.navigation-computer.to_i", Hash(String, String | Int32).new, "actionable")
      end
    when "crystal-hunter"
      if anlyzation.any? { |x| x.options["type"] == "Call" && x.options["name"] == "==" && x.argumments.any? {|x| x["name"] == "true" || x["name"] == "false" } }
        @comments << Comments.new("crystal.crystal-hunter.true_false", Hash(String, String | Int32).new, "actionable")
      end
    when "leap"
      if anlyzation.any? { |x| x.options["type"] == "If" }
        @comments << Comments.new("crystal.leap.if", Hash(String, String | Int32).new, "actionable")
      end
    end
  end
end
