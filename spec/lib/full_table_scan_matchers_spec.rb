require 'spec_helper'

describe FullTableScanMatchers do
  describe ".configuration" do
    it "is an instance of our own configuration class" do
      expect(FullTableScanMatchers.configuration).to be_a FullTableScanMatchers::Configuration
    end
  end
end
