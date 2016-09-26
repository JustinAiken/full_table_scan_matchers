require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec::Matchers.define :full_table_scan do |options = {}|
  if RSpec::Core::Version::STRING =~ /^2/
    def self.failure_message_when_negated(&block)
      failure_message_for_should_not(&block)
    end

    def self.failure_message(&block)
      failure_message_for_should(&block)
    end

    def supports_block_expectations?
      true
    end
  else
    supports_block_expectations
  end

  # Taken from ActionView::Helpers::TextHelper
  def pluralize(count, singular, plural = nil)
    word = if count == 1 || count =~ /^1(\.0+)?$/
             singular
           else
             plural || singular.pluralize
           end

    "#{count || 0} #{word}"
  end

  chain :on do |tables|
    @tables = tables
  end

  define_method :matches? do |block|
    watcher_option = {}
    watcher_option[:tables] = Array(@tables) if defined?(@tables)
    @watcher = FullTableScanMatchers::SQLWatcher.new(watcher_option)
    ActiveSupport::Notifications.subscribed @watcher.to_proc, 'sql.active_record', &block

    replay_logged_with_explain!

    @watcher.count > 0
  end

  def replay_logged_with_explain!
    @watcher.log
      .map!    { |logged| FullTableScanMatchers.configuration.adapter::ExplainResult.new(logged[:sql], backtrace: logged[:backtrace]) }
      .reject! { |logged| !logged.full_table_scan? }
  end

  def output_offenders
    @watcher.log.map(&:to_s).join("\n")
  end

  failure_message_when_negated do |_|
    <<-EOS
expected no full table scans, but #{@watcher.log.count} were made:
#{output_offenders}
    EOS
  end

  failure_message do |_|
    if options[:count]
      expected = pluralize(options[:count], 'full table scan')
      actual   = pluralize(@watcher.count, 'was', 'were')

      output   = "expected #{expected}, but #{actual} made"
      if @watcher.count > 0
        output += ":\n#{output_offenders}"
      end
      output
    else
      'expected full table scans, but none were made'
    end
  end
end
