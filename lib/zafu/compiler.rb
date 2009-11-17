begin
  dir = File.dirname(__FILE__)
  require "#{dir}/parsing_rules"
  require "#{dir}/process/html"
  require "#{dir}/process/ruby_less"
  require "#{dir}/node_context"
  require "#{dir}/process/context"
end

module Zafu
  Compiler = Zafu.parser_with_rules(
    Zafu::ParsingRules,
    Zafu::Process::HTML,
    Zafu::Process::Context,
    Zafu::Process::RubyLess
  )
end
