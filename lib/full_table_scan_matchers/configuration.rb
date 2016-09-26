module FullTableScanMatchers

  # Configuration for the FullTableScanMatchers module.
  class Configuration
    attr_accessor :ignores

    def initialize
      @ignores = []
    end
  end
end
