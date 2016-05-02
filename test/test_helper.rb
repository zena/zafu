require 'pathname'
$LOAD_PATH.unshift((Pathname(__FILE__).dirname +  '..' + 'lib').expand_path)
require 'rubygems'
require 'stringio'
require 'test/unit'
require 'shoulda'
require 'yamltest'
require 'zafu'
require 'zafu/test_helper'
require 'zafu/ordered_hash'
require 'mock/test_compiler'
require 'mock/core_ext'