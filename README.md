[![Build Status](http://img.shields.io/travis/JustinAiken/full_table_scan_matchers/master.svg)](http://travis-ci.org/JustinAiken/full_table_scan_matchers)[![Coveralls branch](http://img.shields.io/coveralls/JustinAiken/full_table_scan_matchers/master.svg)](https://coveralls.io/r/JustinAiken/full_table_scan_matchers?branch=master)

# full_table_scan_matchers

Detect full table scans in your unit tests!  As opposed to just doing basic regexes on the `db/schema.rb` like [rails-best-practices](https://github.com/railsbp/rails_best_practices) does, this actually checks queries made against the database, to ensure and assert that there are indexes for it to use.

## Requirements/Support

- Ruby 2.0+
- ActiveRecord 4+
- ActiveSupport 4+
- mysql2 adapter

## Installation

Add to your `Gemfile`, in the test group:

```ruby
group :test do
  gem 'full_table_scan_matchers', github: 'JustinAiken/full_table_scan_matchers'
end
```

## Usage

```ruby
# No full table scans at all please:
expect { user.posts }.not_to full_table_scan

# Or on just a specific thing:
expect {
  user.posts.joins(:comments).first.comments
}.not_to full_table_scan.on :posts
```

## How's it work?

- It logs all SQL queries made inside the `expect` block
  - ..optionally filtering them to table(s) you care about
- Afterwards, it runs all those through `EXPLAIN`
- Instead of checking `type` for `ALL`, it checks the keys instead
  - Because in test mode, mysql may ignore the index and scan the whole table because it's so small
  - But your production database is much, much larger - we just want to make sure that indexes are available

## Configuration

You can optionally configure a few things:

```ruby
FullTableScanMatchers.configure do |config|
  # Tables to ignore - defaults to none
  # Default: none
  config.ignores = []

  # Database adapter to use - only one for now
  # Default (and only): mysql
  config.adapter = FullTableScanMatchers::DBAdapters::MySql

  # Includes a backtrace in the fail output if this is set to true
  # Default: false
  config.log_backtrace = false

  # Add a proc to strip things from the logged backtraces
  # Default: None
  config.backtrace_filter = Proc.new { |backtrace| backtrace }
end
```

## Postgres?

Currently, this just support mySql.  However, I tried to keep the part that's most-tied to that database (parsing the `EXPLAIN` output) silo'd in an adapter - I'd happily merge any clean PRs that add Postgres (or others)!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Credits

- Primary author: [@JustinAiken](https://github.com/JustinAiken)
- A **lot** of inspiration comes from the excellent [db-query-matchers](https://github.com/brigade/db-query-matchers) by [@brigade](https://github.com/brigade)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JustinAiken/full_table_scan_matchers.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
