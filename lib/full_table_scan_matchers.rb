require 'full_table_scan_matchers/version'
require 'full_table_scan_matchers/db_adapters'
require 'full_table_scan_matchers/db_adapters/mysql'
require 'full_table_scan_matchers/db_adapters/mysql/explain_result'
require 'full_table_scan_matchers/sql_watcher'
require 'full_table_scan_matchers/matchers/full_table_scan'
require 'full_table_scan_matchers/configuration'

require 'active_record'
require 'active_support'

# Main module that holds global configuration.
module FullTableScanMatchers
  class << self
    attr_writer :configuration
  end

  # Gets the current configuration
  # @return [FullTableScanMatchers::Configuration] the active configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Resets the current configuration.
  # @return [FullTableScanMatchers::Configuration] the active configuration
  def self.reset_configuration
    @configuration = Configuration.new
  end

  # Updates the current configuration.
  # @example
  #   FullTableScanMatchers.configure do |config|
  #     config.ignores = [/SELECT.*FROM.*users/]
  #   end
  #
  def self.configure
    yield configuration
  end
end
