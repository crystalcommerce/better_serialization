$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'activerecord'
require 'better_serialization'

Spec::Runner.configure do |config|
  
end

RAILS_ENV="test"
ActiveRecord::Base.logger = Logger.new(StringIO.new) # make it think it has a logger
 
ActiveRecord::Base.configurations = {
  "test" => {
    :adapter => 'sqlite3',
    :database => ":memory:"
  }
}
ActiveRecord::Base.establish_connection
silence_stream(STDOUT) {require 'schema'}

require "models/order_log"
require "models/customer"
require "models/line_item"
require "models/product"
require "models/person"
require "models/directory"
