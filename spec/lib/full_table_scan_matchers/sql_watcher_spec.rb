require 'spec_helper'

describe FullTableScanMatchers::SQLWatcher do
  let(:watcher) { described_class.new }

  describe "#callback" do
    let(:make_callback) { watcher.callback :foo, :bar, :biz, :baz, {sql: sql} }
    let(:last_logged)   { watcher.log.last }

    describe "with a SELECT statement" do
      let(:sql) { "SELECT * FROM users" }

      it "increments the counter" do
        expect { make_callback }.to change { watcher.count }.by 1
      end

      it "logs the statement" do
        make_callback
        expect(last_logged).to eq sql
      end
    end

    describe "with a EXPLAIN SELECT statement" do
      let(:sql) { "EXPLAIN SELECT * FROM users" }

      it "increments the counter" do
        expect { make_callback }.not_to change { watcher.count }
      end

      it "logs the statement" do
        make_callback
        expect(last_logged).to be_nil
      end
    end
  end
end
