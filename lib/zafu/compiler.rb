require 'zafu/parser/zafu_rules'
require 'zafu/parser/zafu_tags'
require 'zafu/parser/ruby_less_tags'

module Zafu
  Compiler = Zafu::Parser.parser_with_rules(
    Zafu::Parser::ZafuRules,
    Zafu::Parser::ZafuTags,
    Zafu::Parser::ZafuContext,
    Zafu::Parser::RubyLessTags
  )
end