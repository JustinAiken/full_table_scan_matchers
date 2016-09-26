module FullTableScanMatchers

  # Configuration for the FullTableScanMatchers module.
  class Configuration
    attr_accessor :ignores, :adapter

    def initialize
      @ignores = []
      @adapter = DBAdapters::MySql
    end
  end
end
