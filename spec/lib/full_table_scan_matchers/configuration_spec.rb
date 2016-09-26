require 'spec_helper'

describe FullTableScanMatchers::Configuration do
  context 'defaults' do
    let(:configuration) { described_class.new }

    it "are initialized" do
      expect(configuration.ignores).to          eq []
      expect(configuration.adapter).to          eq FullTableScanMatchers::DBAdapters::MySql
      expect(configuration.log_backtrace).to    eq false
      expect(configuration.backtrace_filter).to be_a Proc
    end
  end
end
