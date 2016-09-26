require 'ostruct'
require 'active_support/core_ext/module/delegation'

module FullTableScanMatchers
  module DBAdapters
    module MySql
      class ExplainResult
        attr_accessor :sql_statement, :struct

        delegate *%i{
          id select_type table type possible_keys key key_len ref rows extra
        }, to: :struct

        def initialize(sql_statement)
          @sql_statement = sql_statement
        end

        # TODO - Make this much more clever:
        def full_table_scan?
          key == "NULL" && possible_keys == "NULL"
        end

      private

        def struct
          @struct ||= OpenStruct.new(as_hash)
        end

        def as_hash
          @as_hash ||= begin
            explain_rows   = explained_result.split("\n")
            keys           = explain_rows[1].split("|").map(&:strip).reject(&:blank?).map(&:downcase)
            values         = explain_rows[3].split("|").map(&:strip).reject(&:blank?)

            Hash[keys.zip(values)].symbolize_keys!
          end
        end

        def explained_result
          @explained_result ||= ActiveRecord::Base.connection.explain(sql_statement)
        end
      end
    end
  end
end
