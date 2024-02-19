require "json"
require "http/client"

module CheckJson
  class Notes
    include JSON::Serializable
    property comments : Array(Note)?
  end

  class Note
    include JSON::Serializable
    property comment : String
    property params : Hash(String, String | Int32 | Bool | Float64)
    property type : String
  end

  def self.check_file(test_casse)
    notes = Notes.from_json(File.read("tests/#{test_casse}/expected_analysis.json"))
    if comments = notes.comments
      comments.each do |note|
        content = file!(note.comment)
        note.params.each do |key, value|
          unless content.includes?("%{#{key}}") # TODO: Make this a bit more robust
            raise "Couldn't find #{key} in #{note.comment}" # TODO: Improve Error message
          end
        end
      end
    end
  end

    protected def self.file!(path)
    path = path.gsub(".", "/")
    response = HTTP::Client.get("https://raw.githubusercontent.com/exercism/website-copy/main/analyzer-comments/#{path}.md")
    case response.status_code
    when 200
      return response.body
    when 404
      raise "Couldn't find coresponding file for #{path}"
    else
      raise "Error while requesting the #{path} data file from GitHub... " +
            "Status was #{response.status_code}"
    end
  end
end

Dir.new("tests").each_child do |test_casse|
  CheckJson.check_file(test_casse)
end
