require 'zafu/markup'
require 'zafu/parsing_rules'
#  require 'zafu/process/ajax'
require 'zafu/process/html'
require 'zafu/process/ruby_less'
require 'zafu/node_context'
require 'zafu/process/context'

module Zafu
  Compiler = Zafu.parser_with_rules(
    Zafu::ParsingRules,
#    Zafu::Process::Ajax,
    Zafu::Process::HTML,
    Zafu::Process::Context,
    Zafu::Process::RubyLess
  )
end
