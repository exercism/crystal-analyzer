require "json"
require "./exercise-analyser"

class Analysis
  include JSON::Serializable
  getter summery : String?
  property comments : Array(Comments)

  def initialize(summery : String?, comments : Array(Comments))
    @summery = summery
    @comments = comments
  end
end

class Comments
  include JSON::Serializable
  getter comment : String
  getter params : Hash(String, String | Int32)
  getter type : String

  def initialize(comment : String, params : Hash(String, String | Int32), type : String)
    @comment = comment
    @params = params
    @type = type
  end
end

class Analyzer
  Types = {
    "Error"      => "error",
    "Warning"    => "warning",
    "Convention" => "convention",
  }

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
    @result = @result + exericse_analyzer.comments
  end
end

ARGV[0]

if ARGV.size >= 1
  anylyser = Analyzer.new
  anylyser.load_result(ARGV[0])
  anylyser.analyze(ARGV[3], ARGV[2])
  result = anylyser.result

  File.write(ARGV[1], Analysis.new("test", result).to_json)
end
