require 'mock/params'
require 'mock/process'
require 'mock/classes'

TestCompiler = Zafu.parser_with_rules(
  Zafu::All,
  Mock::Params,
  Mock::Process
)
