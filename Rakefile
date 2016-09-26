require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :db do
  desc "Create test database"
  task :create_test do
    require 'mysql2'

    @db_host = "localhost"
    @db_user = "root"
    @db_pass = ""
    @db_name = "full_table_scan_matchers_test"

    client = Mysql2::Client.new(host: @db_host, username: @db_user, password: @db_pass)
    client.query("DROP DATABASE IF EXISTS #{@db_name}")
    client.query("CREATE DATABASE #{@db_name}")
    client.close
  end
end
