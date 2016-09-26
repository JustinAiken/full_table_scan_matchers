require 'spec_helper'

describe FullTableScanMatchers::DBAdapters::MySql::ExplainResult  do
  let(:connection) { double ActiveRecord::ConnectionAdapters::AbstractAdapter, explain: explain_table }
  before           { allow(ActiveRecord::Base).to receive(:connection).and_return connection }
  subject(:result) { described_class.new explain_table }

  describe "example using an index" do
    let(:explain_table) do
      <<-TEXT
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
        | id | select_type | table | type | possible_keys          | key                    | key_len | ref   | rows | Extra       |
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
        |  1 | SIMPLE      | posts | ref  | index_posts_on_user_id | index_posts_on_user_id | 5       | const |    1 | Using where |
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
      TEXT
    end

    it 'parses the explain table' do
      expect(result.id).to            eq '1'
      expect(result.select_type).to   eq 'SIMPLE'
      expect(result.table).to         eq 'posts'
      expect(result.type).to          eq 'ref'
      expect(result.possible_keys).to eq 'index_posts_on_user_id'
      expect(result.key).to           eq 'index_posts_on_user_id'
      expect(result.key_len).to       eq '5'
      expect(result.ref).to           eq 'const'
      expect(result.rows).to          eq '1'
      expect(result.extra).to         eq 'Using where'
    end

    it { should_not be_full_table_scan }
  end

  describe "example not using an index" do
    let(:explain_table) do
      <<-TEXT
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
        | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
        |  1 | SIMPLE      | posts | ALL  | NULL          | NULL | NULL    | NULL | 1    | Using where |
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
      TEXT
    end

    it 'parses the explain table' do
      expect(result.id).to            eq '1'
      expect(result.select_type).to   eq 'SIMPLE'
      expect(result.table).to         eq 'posts'
      expect(result.type).to          eq 'ALL'
      expect(result.possible_keys).to eq 'NULL'
      expect(result.key).to           eq 'NULL'
      expect(result.key_len).to       eq 'NULL'
      expect(result.ref).to           eq 'NULL'
      expect(result.rows).to          eq '1'
      expect(result.extra).to         eq 'Using where'
    end

    it { should be_full_table_scan }
  end
end
