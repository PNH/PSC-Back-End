############### START - Develop ###############

# # Load DSL and set up stages
# require 'capistrano/setup'

# # Include default deployment tasks
# require 'capistrano/deploy'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

# require "capistrano/scm/git"
# install_plugin Capistrano::SCM::Git

# # Load custom tasks from `lib/capistrano/tasks` if you have any defined
# Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

############### END - Develop ###############


############### START - Stging / Production Set ###############


# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'rvm1/capistrano3'
require 'capistrano/rails'
require 'capistrano/secrets_yml'
require 'capistrano/rake'
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }


############### END - Stging / Production Set ###############
