module FullTableScanMatchers
  class SQLWatcher
    attr_reader :log, :options

    def initialize(options = {})
      @log     = []
      @options = options
    end

    # Turns a SQLWatcher instance into a lambda. Designed to be used when
    # subscribing to events through the ActiveSupport::Notifications module.
    #
    # @return [Proc]
    def to_proc
      lambda &method(:callback)
    end

    # Method called from the ActiveSupport::Notifications module (through the
    # lambda created by `to_proc`) when an SQL query is made.
    #
    # @param _name       [String] name of the event
    # @param _start      [Time]   when the instrumented block started execution
    # @param _finish     [Time]   when the instrumented block ended execution
    # @param _message_id [String] unique ID for this notification
    # @param payload     [Hash]   the payload
    #
    def callback(_name, _start,  _finish, _message_id, payload)
      sql_statement = payload[:sql]

      return if     sql_statement =~ /EXPLAIN /i # That's from us, don't EXPLAIN the EXPLAINS!
      return unless sql_statement =~ /SELECT /   # Only selects for now
      return if     any_match? ignores, sql_statement
      return unless any_match? tables,  sql_statement if options[:tables]

      backtrace = if FullTableScanMatchers.configuration.log_backtrace
        raw_backtrace      = caller
        filtered_backtrace = FullTableScanMatchers.configuration.backtrace_filter.call(raw_backtrace)
        "#{filtered_backtrace.join("\n")}\n"
      else
        nil
      end

      @log << {sql: sql_statement.strip, backtrace: backtrace}
    end

    def count
      log.count
    end

  private

    def tables
      Array(options[:tables]).map { |table_name| /FROM\s+`?#{table_name.to_s}`?/i }
    end

    def ignores
      FullTableScanMatchers.configuration.ignores
    end

    def any_match?(patterns, sql)
      patterns.any? { |pattern| sql =~ pattern }
    end
  end
end
