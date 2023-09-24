require "compiler/crystal/syntax"

class Types
  getter options : Hash(String, String?)
  getter argumments : Array(Hash(String, String?))
  getter inside_method : String?
  getter inside_class : String?
  getter inside_struct : String?
  getter inside_enum : String?
  getter inside_module : String?

  def initialize(@options : Hash(String, String?), @argumments : Array(Hash(String, String?)), @inside_method : String? = nil, @inside_class : String? = nil, @inside_struct : String? = nil, @inside_enum : String? = nil, @inside_module : String? = nil, @concepts = [] of String)
  end
end

class GeneralAnalyzer < Crystal::Visitor

  @types = Array(Types).new
  @concepts = [] of String
  @inside_class : String? = nil
  @inside_struct : String? = nil
  @inside_enum : String? = nil
  @inside_module : String? = nil
  @inside_method : String? = nil

  property types : Array(Types), concepts : Array(String)

  def initialize
  end

  def visit(node : Crystal::ClassDef)
    @inside_class = node.name.to_s
    true
  end

  def visit(node : Crystal::CStructOrUnionDef)
    @inside_struct = node.name.to_s
    true
  end

  def visit(node : Crystal::EnumDef)
    @inside_enum = node.name.to_s
    true
  end

  def visit(node : Crystal::ModuleDef)
    @inside_module = node.name.to_s
    true
  end

  def visit(node : Crystal::Def)
    options = Hash(String, String?).new
    options.merge!({"name" => node.name.to_s, "type" => "Def"})
    argumments : Array(Hash(String, String?)) = node.args.map do |arg|
      argumment = Hash(String, String?).new
      argumment.merge({"name" => arg.name.to_s, "type" => "Arg", "default_argument" => arg.default_value ? arg.default_value.to_s : nil})
      argumment
    end 
    types << Types.new(options, argumments, @inside_method, @inside_class, @inside_struct, @inside_enum, @inside_module)
    concepts << "oop" if node.name.to_s == "initialize"
    @inside_method = node.name.to_s
    true
  end

  def visit(node : Crystal::Call)
    options = Hash(String, String?).new
    options.merge!({"name" => node.name.to_s, "type" => "Call", "receiver" => node.obj.to_s})
    argumments = node.args.map do |arg|
      argumment = Hash(String, String?).new
      argumment.merge({"name" => arg.to_s, "type" => "Arg"})
      argumment
    end
    types << Types.new(options, argumments, @inside_method, @inside_class, @inside_struct, @inside_enum, @inside_module)
    true
  end

  def visit(node : Crystal::Assign)
    p node
    options = Hash(String, String?).new
    options.merge!({"name" => node.target.to_s, "type" => "Assign", "value" => node.value.to_s})
    types << Types.new(options, Array(Hash(String, String?)).new, @inside_method, @inside_class, @inside_struct, @inside_enum, @inside_module)
    true
  end

  {% for type, name in {"ClassDef": "class", "CStructOrUnionDef": "struct", "EnumDef": "enum", "ModuleDef": "module", "Def": "method"} %}
  def end_visit(node : Crystal::{{type.id}})
    @inside_{{name.id}} = nil
    true
  end
  {% end %}

  def visit(node)
    true
  end
end
