require 'bundler/setup'
require 'rspec/autorun'

# deps
require 'sqlite3'
require 'active_record'
require_relative '../lib/better_serialization'
require 'logger'

ActiveRecord::Base.logger = Logger.new(StringIO.new) # make it think it has a logger
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ":memory:"
)

silence_stream(STDOUT) { require 'schema' }

Dir.glob(File.dirname(__FILE__) + "/models/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
