require 'yaml'

class TestClass
  def initialize(parameters = [])
    @parameters = parameters
  end
  attr_accessor :parameters
end



data = nil

puts 'load marshal'
File.open( __dir__ + "/test.marshal", "r+" ) do |input_file|
  data = Marshal.load( input_file )
end

# Need to hack TestClass.marshal_load to force string encoding of TestClass.parameters to utf-8 so that the string doesn't end up as !binary in the yaml.
# it's absolutely critical that after these operations test2.marshal ends up exactly the same as the original test.marshal

# calling this manually after Marshal.load achieves what I need
# data['root'].parameters.each do |p|
#   p.force_encoding("utf-8")
# end

# in practice I'm Marshal loading a large structure with many nested objects so I can't do it manually like this therefore I need to move that into TestClass.marshal_load

puts 'dump yaml'
File.open( __dir__ + "/test.yaml", File::WRONLY|File::CREAT|File::TRUNC|File::BINARY) do |output_file|
  File.write(output_file, YAML::dump(data))
end

puts 'load yaml'
File.open( __dir__ + "/test.yaml", "r+" ) do |input_file|
  data = YAML::unsafe_load( input_file )
end

# this reverts the strings back to 8bit - needs to be done in TestClass.marshal_dump
# data['root'].parameters.each do |p|
#   p.force_encoding("ASCII-8BIT")
# end

puts 'dump marshal'
File.open( __dir__ + "/test2.marshal", "w+" ) do |output_file|
  Marshal.dump( data, output_file )
end
