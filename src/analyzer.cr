require "json"
require "representer/api"
require "./exercise-analyser"

class Analysis
  include JSON::Serializable
  getter summery : String?
  property comments : Array(Comments)

  def initialize(@comments : Array(Comments), @summery : String? = nil)
  end
end

class Comments
  include JSON::Serializable
  getter comment : String
  getter params : Hash(String, String | Int32)
  getter type : String

  def initialize(@comment : String, @params : Hash(String, String | Int32), @type : String)
  end
end

class Analyzer
  @result : Array(Comments) = [] of Comments

  property result

  def load_result(path : String)
    JSON.parse(File.read(path))["sources"].as_a.each do |value|
      value["issues"].as_a.each do |line|
        case line["severity"]
        when "Error"
          result << Comments.new("crystal.ameba.error", {"message" => line["message"].to_s, "line_number" => line["location"]["line"].as_i}, "essential")
        when "Warning"
          result << Comments.new("crystal.ameba.warning", {"message" => line["message"].to_s, "line_number" => line["location"]["line"].as_i}, "actionable")
        when "Convention"
          result << Comments.new("crystal.ameba.convention", {"message" => line["message"].to_s, "line_number" => line["location"]["line"].as_i}, "informative")
        end
      end
    end
  end

  def analyze(exercise : String, path : String)
    exericse_analyzer = ExerciseAnayzer.new(exercise, path)
    exericse_analyzer.exercise_tags
    @result += exericse_analyzer.comments
    exemplar_comment
  end

  def exemplar_comment
    unless ARGV[4].empty?
      if exemplar?(ARGV[4])
        @result << Comments.new("crystal.general.same_as_exemplar", Hash(String, String | Int32).new, "celebratory")
      end
    end
  end
  
  private def exemplar?(exemplar_path : String) : Bool
    representer1 = Representer.new
    representer1.parse_file(Path.new(ARGV[2]))
    representer1.represent

    first_representation = representer1.representation
    representer1.update_data([] of String)
    representer1.update_counter(0)

    representer2 = Representer.new
    representer2.parse_file(Path.new(exemplar_path))
    representer2.represent

    return first_representation == representer2.representation
  end
end

if ARGV.size >= 4
  anylyser = Analyzer.new
  anylyser.load_result(ARGV[0])
  anylyser.analyze(ARGV[3], ARGV[2])
  result = anylyser.result

  File.write(ARGV[1], Analysis.new(result).to_json)
end
