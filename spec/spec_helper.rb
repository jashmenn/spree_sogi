unless defined? SPREE_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["SPREE_ENV_FILE"]
    require ENV["SPREE_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/SPREE/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{SPREE_ROOT}/spec/spec_helper"

if File.directory?(File.dirname(__FILE__) + "/scenarios")
  Scenario.load_paths.unshift File.dirname(__FILE__) + "/scenarios"
end
if File.directory?(File.dirname(__FILE__) + "/matchers")
  Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each {|file| require file }
end

SOGI_FIXTURES_PATH = File.dirname(__FILE__) + "/fixtures" unless defined? SOGI_FIXTURES_PATH

require 'bigdecimal'
require 'bigdecimal/util'

BigDecimal.class_eval do
  def to_d
    return self
  end
end

ActionController::TestResponse.class_eval do
  def kind_of_success?
   (200..299).include?(code.to_i)
  end
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  # config.use_instantiated_fixtures  = false
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures'
  config.fixture_path = File.dirname(__FILE__) + '/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  config.global_fixtures = :states, :countries
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end
