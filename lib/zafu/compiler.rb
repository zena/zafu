require 'zafu/parsing_rules'
require 'zafu/process/html'
require 'zafu/process/ruby_less'
require 'zafu/process/context'

module Zafu
  Compiler = Zafu::Parser.parser_with_rules(
    Zafu::ParsingRules,
    Zafu::Process::HTML,
    Zafu::Process::Context,
    Zafu::Process::RubyLess
  )
end