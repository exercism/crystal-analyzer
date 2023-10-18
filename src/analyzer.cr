require "json"
require "representer/api"
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
    @result += exericse_analyzer.comments
    exemplar_comment
    todo_comment(path)
  end

  def exemplar_comment
    if exemplar?
      @result << Comments.new("crystal.general.same_as_exemplar",  Hash(String, String | Int32).new, "informative")
    end
  end

  def todo_comment(path)
    file_content = File.read(path)
    file_content.each_line.with_index do |line, idx|
      if line.includes?("# TODO:")
        options = Hash(String, String | Int32){
          "line_number" => idx}
        @result << Comments.new("crystal.general.todo",  options, "informative")
        break
      end
    end
  end

  private def exemplar? : Bool
    if File.exists?(ARGV[4])
      representer1 = Representer.new
      representer2 = Representer.new

      representer1.parse_file(Path.new(ARGV[2]))
      representer2.parse_file(Path.new(ARGV[4]))

      representer1.represent
      representer2.represent

      return representer1.representation == representer2.representation
    end
    false
  end
end

ARGV[0]

if ARGV.size >= 4
  anylyser = Analyzer.new
  anylyser.load_result(ARGV[0])
  anylyser.analyze(ARGV[3], ARGV[2])
  result = anylyser.result

  File.write(ARGV[1], Analysis.new(nil, result).to_json)
end
