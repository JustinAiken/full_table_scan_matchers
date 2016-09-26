require 'spec_helper'

describe FullTableScanMatchers::SQLWatcher do
  let(:watcher) { described_class.new options }
  let(:options) { {} }

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

      context "that doesn't match the tables option" do
        let(:options) { {tables: :posts} }

        it "doesn't change anything" do
          expect { make_callback }.not_to change { watcher.count }
          expect(last_logged).to be_nil
        end
      end

      context "that does match the tables option" do
        let(:options) { {tables: :users} }

        it "does log" do
          expect { make_callback }.to change { watcher.count }.by 1
          expect(last_logged).to eq "SELECT * FROM users"
        end
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
