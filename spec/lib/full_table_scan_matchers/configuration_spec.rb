require 'spec_helper'

describe FullTableScanMatchers::Configuration do
  context 'defaults' do
    let(:configuration) { described_class.new }

    it "are initialized" do
      expect(configuration.ignores).to eq []
      expect(configuration.adapter).to eq FullTableScanMatchers::DBAdapters::MySql
    end
  end
end
