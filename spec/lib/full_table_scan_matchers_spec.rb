require 'spec_helper'

describe FullTableScanMatchers do
  describe ".configuration" do
    it "is an instance of our own configuration class" do
      expect(FullTableScanMatchers.configuration).to be_a FullTableScanMatchers::Configuration
    end
  end

  describe ".configure / .reset_configuration" do
    before do
      FullTableScanMatchers.configure do |config|
        config.ignores = [:foo]
      end
    end

    it "sets and resets the config" do
      expect { FullTableScanMatchers.reset_configuration}.to change {
        FullTableScanMatchers.configuration.ignores
      }.from([:foo]).to []
    end
  end
end
