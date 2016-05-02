require 'yaml'

d = Dir["./**/*.yml"]
d.each do |file|
  begin
    puts "checking : #{file}"
    f =  YAML.load_file(file)
  rescue Exception
    puts "failed to read #{file}: #{$!}"
  end
end