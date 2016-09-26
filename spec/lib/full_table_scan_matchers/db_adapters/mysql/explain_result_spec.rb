require 'spec_helper'

describe FullTableScanMatchers::DBAdapters::MySql::ExplainResult  do
  let(:connection) { double ActiveRecord::ConnectionAdapters::AbstractAdapter, explain: explain_table }
  before           { allow(ActiveRecord::Base).to receive(:connection).and_return connection }
  let(:sql)        { "SELECT * FROM posts WHERE posts.user_id = ?" }
  subject(:result) { described_class.new sql }

  describe "example using an index" do
    let(:explain_table) do
      <<-TEXT
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
        | id | select_type | table | type | possible_keys          | key                    | key_len | ref   | rows | Extra       |
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
        |  1 | SIMPLE      | posts | ref  | index_posts_on_user_id | index_posts_on_user_id | 5       | const |    1 | Using where |
        +----+-------------+-------+------+------------------------+------------------------+---------+-------+------+-------------+
        1 row in set (0.00 sec)
      TEXT
    end

    it 'parses the explain table' do
      expect(result.structs[0].id).to            eq '1'
      expect(result.structs[0].select_type).to   eq 'SIMPLE'
      expect(result.structs[0].table).to         eq 'posts'
      expect(result.structs[0].type).to          eq 'ref'
      expect(result.structs[0].possible_keys).to eq 'index_posts_on_user_id'
      expect(result.structs[0].key).to           eq 'index_posts_on_user_id'
      expect(result.structs[0].key_len).to       eq '5'
      expect(result.structs[0].ref).to           eq 'const'
      expect(result.structs[0].rows).to          eq '1'
      expect(result.structs[0].extra).to         eq 'Using where'
    end

    it { should_not be_full_table_scan }

    it "can spit itself out as a string" do
      expect(result.to_s).to eq <<-STRING.strip
SQL:  SELECT * FROM posts WHERE posts.user_id = ?
INFO: id: 1, select_type: SIMPLE, table: posts, type: ref, possible_keys: index_posts_on_user_id, key: index_posts_on_user_id, key_len: 5, ref: const, rows: 1, extra: Using where
STRING
    end
  end

  describe "example not using an index" do
    let(:explain_table) do
      <<-TEXT
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
        | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
        |  1 | SIMPLE      | posts | ALL  | NULL          | NULL | NULL    | NULL | 1    | Using where |
        +----+-------------+-------+------+---------------+------+---------+------+------+-------------+
        1 row in set (0.00 sec)
      TEXT
    end

    it 'parses the explain table' do
      expect(result.structs[0].id).to            eq '1'
      expect(result.structs[0].select_type).to   eq 'SIMPLE'
      expect(result.structs[0].table).to         eq 'posts'
      expect(result.structs[0].type).to          eq 'ALL'
      expect(result.structs[0].possible_keys).to eq 'NULL'
      expect(result.structs[0].key).to           eq 'NULL'
      expect(result.structs[0].key_len).to       eq 'NULL'
      expect(result.structs[0].ref).to           eq 'NULL'
      expect(result.structs[0].rows).to          eq '1'
      expect(result.structs[0].extra).to         eq 'Using where'
    end

    it { should be_full_table_scan }

    it "can spit itself out as a string" do
      expect(result.to_s).to eq <<-STRING.strip
SQL:  SELECT * FROM posts WHERE posts.user_id = ?
FAIL: id: 1, select_type: SIMPLE, table: posts, type: ALL, possible_keys: NULL, key: NULL, key_len: NULL, ref: NULL, rows: 1, extra: Using where
STRING
    end
  end

  describe "with a complex query" do
    let(:explain_table) do
      <<-TEXT
        +----+--------------------+-------+--------+----------------------------------------------+------------------------+---------+----------------------------+------+----------------------------------------------+
        | id | select_type        | table | type   | possible_keys                                | key                    | key_len | ref                        | rows | Extra                                        |
        +----+--------------------+-------+--------+----------------------------------------------+------------------------+---------+----------------------------+------+----------------------------------------------+
        |  1 | PRIMARY            | foos  | ref    | index_foos_on_posts_id,index_foos_on_user_id | index_foos_on_posts_id | 5       | const                      |    1 | Using where; Using temporary; Using filesort |
        |  1 | PRIMARY            | bars  | ref    | index_bars_on_user_id                        | index_bars_on_user_id  | 5       | some_db.foos.user_id       |    1 | Using where                                  |
        |  1 | PRIMARY            | users | eq_ref | PRIMARY                                      | PRIMARY                | 4       | some_db.foos.user_id       |    1 | Using where                                  |
        |  2 | DEPENDENT SUBQUERY | bizs  | ref    | some_index,index_bizs_on_user_id             | some_index             | 10      | const,some_db.bars.user_id |    1 | Using index                                  |
        +----+--------------------+-------+--------+----------------------------------------------+------------------------+---------+----------------------------+------+----------------------------------------------+
        4 rows in set (0.00 sec)
      TEXT
    end

    it 'parses the explain table for all rows' do
      expect(result.structs[0].id).to            eq '1'
      expect(result.structs[0].select_type).to   eq 'PRIMARY'
      expect(result.structs[0].table).to         eq 'foos'
      expect(result.structs[0].type).to          eq 'ref'
      expect(result.structs[0].possible_keys).to eq 'index_foos_on_posts_id,index_foos_on_user_id'
      expect(result.structs[0].key).to           eq 'index_foos_on_posts_id'
      expect(result.structs[0].key_len).to       eq '5'
      expect(result.structs[0].ref).to           eq 'const'
      expect(result.structs[0].rows).to          eq '1'
      expect(result.structs[0].extra).to         eq 'Using where; Using temporary; Using filesort'

      expect(result.structs[1].id).to            eq '1'
      expect(result.structs[1].select_type).to   eq 'PRIMARY'
      expect(result.structs[1].table).to         eq 'bars'
      expect(result.structs[1].type).to          eq 'ref'
      expect(result.structs[1].possible_keys).to eq 'index_bars_on_user_id'
      expect(result.structs[1].key).to           eq 'index_bars_on_user_id'
      expect(result.structs[1].key_len).to       eq '5'
      expect(result.structs[1].ref).to           eq 'some_db.foos.user_id'
      expect(result.structs[1].rows).to          eq '1'
      expect(result.structs[1].extra).to         eq 'Using where'

      expect(result.structs[2].id).to            eq '1'
      expect(result.structs[2].select_type).to   eq 'PRIMARY'
      expect(result.structs[2].table).to         eq 'users'
      expect(result.structs[2].type).to          eq 'eq_ref'
      expect(result.structs[2].possible_keys).to eq 'PRIMARY'
      expect(result.structs[2].key).to           eq 'PRIMARY'
      expect(result.structs[2].key_len).to       eq '4'
      expect(result.structs[2].ref).to           eq 'some_db.foos.user_id'
      expect(result.structs[2].rows).to          eq '1'
      expect(result.structs[2].extra).to         eq 'Using where'

      expect(result.structs[3].id).to            eq '2'
      expect(result.structs[3].select_type).to   eq 'DEPENDENT SUBQUERY'
      expect(result.structs[3].table).to         eq 'bizs'
      expect(result.structs[3].type).to          eq 'ref'
      expect(result.structs[3].possible_keys).to eq 'some_index,index_bizs_on_user_id'
      expect(result.structs[3].key).to           eq 'some_index'
      expect(result.structs[3].key_len).to       eq '10'
      expect(result.structs[3].ref).to           eq 'const,some_db.bars.user_id'
      expect(result.structs[3].rows).to          eq '1'
      expect(result.structs[3].extra).to         eq 'Using index'
    end

    it { should_not be_full_table_scan }

    it "can spit itself out as a string" do
      expect(result.to_s).to eq <<-STRING.strip
SQL:  SELECT * FROM posts WHERE posts.user_id = ?
INFO: id: 1, select_type: PRIMARY, table: foos, type: ref, possible_keys: index_foos_on_posts_id,index_foos_on_user_id, key: index_foos_on_posts_id, key_len: 5, ref: const, rows: 1, extra: Using where; Using temporary; Using filesort
INFO: id: 1, select_type: PRIMARY, table: bars, type: ref, possible_keys: index_bars_on_user_id, key: index_bars_on_user_id, key_len: 5, ref: some_db.foos.user_id, rows: 1, extra: Using where
INFO: id: 1, select_type: PRIMARY, table: users, type: eq_ref, possible_keys: PRIMARY, key: PRIMARY, key_len: 4, ref: some_db.foos.user_id, rows: 1, extra: Using where
INFO: id: 2, select_type: DEPENDENT SUBQUERY, table: bizs, type: ref, possible_keys: some_index,index_bizs_on_user_id, key: some_index, key_len: 10, ref: const,some_db.bars.user_id, rows: 1, extra: Using index
STRING
    end
  end
end
