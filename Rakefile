require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'active_record'
require 'yaml'

namespace :db do
  db_config       = YAML::load(File.open('config/database.yml'))['test']
  db_config_admin = db_config.merge('database' => 'mysql')

  desc "Create the database"
  task :create do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.create_database(db_config["database"])
    puts "Database created."
  end

  desc "Drop the database"
  task :drop do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.drop_database(db_config["database"])
    puts "Database deleted."
  end

  desc "Reset the database"
  task reset: [:drop, :create]
end
