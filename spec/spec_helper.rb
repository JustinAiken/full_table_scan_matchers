$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'full_table_scan_matchers'
require 'mysql2'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
