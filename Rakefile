# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'zafu/info'

task :default => 'spec:run'

PROJ.name = 'zafu'
PROJ.authors = 'Gaspard Bucher'
PROJ.email = 'gaspard@teti.ch'
PROJ.url = 'http://zenadmin.org/zafu'
PROJ.version = Zafu::VERSION
PROJ.rubyforge.name = 'zafu'
PROJ.readme_file = 'README.rdoc'

PROJ.spec.opts << '--color'
PROJ.gem.dependencies << ['rubyless', '>= 0.3.5']

# EOF
