require 'zafu/parsing_rules'
require 'zafu/process/ajax'
require 'zafu/process/html'
require 'zafu/process/ruby_less'
require 'zafu/process/context'
require 'zafu/process/conditional'
require 'zafu/process/forms'

module Zafu
  All = [
    Zafu::ParsingRules,
    Zafu::Process::HTML,
    Zafu::Process::Context,
    Zafu::Process::Conditional,
    Zafu::Process::RubyLess,
    Zafu::Process::Ajax,
    Zafu::Process::Forms,
  ]
end
