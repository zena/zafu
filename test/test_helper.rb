require 'rubygems'
require 'stringio'
require 'test/unit'
require 'shoulda'
require 'zafu'
require 'zafu/test_helper'
require 'mock/params'

TestCompiler = Zafu.parser_with_rules(Zafu::All, Mock::Params)
