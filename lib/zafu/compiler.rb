require 'zafu/parser'
require 'zafu/all'

module Zafu
  Compiler = Zafu.parser_with_rules(Zafu::All)
end
