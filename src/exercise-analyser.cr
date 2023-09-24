require "compiler/crystal/syntax"
require "./exercises/*"
require "./analyzer"
require "./visitor_analyzer"

class ExerciseAnayzer
  getter exercise, anlyzation
  property comments, concepts

  @comments = Array(Comments).new
  @anlyzation : Array(Types)

  def initialize(exercise : String, path : String)
    file_content = File.read(path)
    solution = Crystal::Parser.new(file_content)
    ast = solution.parse
    analyser = GeneralAnalyzer.new
    analyser.accept(ast)
    @anlyzation = analyser.types
    @concepts = analyser.concepts # Adding the possibilty of marking an exercise as having a certain concept
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
        @comments << Comments.new("crystal.two-fer.no_def_arg", Hash(String, String | Int32).new, "warrning")
      end
      if anlyzation.any? { |x| x.options["name"] == "+" && x.options["type"] == "Call" && x.inside_method == "two_fer" }
        @comments << Comments.new("rystal.two-fer.string_format", Hash(String, String | Int32).new, "warrning")
      end
    when "arys-amazing-lasagna"
      if anlyzation.none? { |x| x.options["name"] == "preparation_time_in_minutes" && x.options["type"] == "Call" && x.inside_method == "total_time_in_minutes" }
        @comments << Comments.new("crystal.arys-amazing-lasagna.no-call", Hash(String, String | Int32).new, "warrning")
      end
      if anlyzation.none? { |x| x.options["name"] == "EXPECTED_MINUTES_IN_OVEN" && x.options["name"] == "Assign" && x.inside_method == "remaining_minutes_in_oven" }
        @comments << Comments.new("crystal.arys-amazing-lasagna.no-constant", Hash(String, String | Int32).new, "warrning")
      end
    when "navigation-computer"
      if anlyzation.any? do |x|
           {"NEPTUNE_DISTANCE", "MARS_DISTANCE", "ATMOSPHERE_DISTANCE"}.includes?(x.options["name"]) && x.options["type"] == "Assign" && x.options["value"].includes?("to_i")
         end
        @comments << Comments.new("crystal.navigation-computer.no-to_i", Hash(String, String | Int32).new, "warrning")
      end
    end
  end
end
