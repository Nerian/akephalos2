require "yaml"
YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

root = File.expand_path('../../', __FILE__)
lib_paths = [root] + %w(vendor lib vendor).collect { |dir| File.join(root, dir) }
(lib_paths).each do |dir|
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)
end

require 'akephalos'

spec_dir = nil
$LOAD_PATH.detect do |dir|
  if File.exists? File.join(dir, "capybara.rb")
    spec_dir = File.expand_path(File.join(dir,"..","spec"))
    $LOAD_PATH.unshift( spec_dir )
  end
end
                             
RSpec.configure do |config|
  running_with_jruby = RUBY_PLATFORM =~ /java/
  
  config.treat_symbols_as_metadata_keys_with_true_values = true

  warn "[AKEPHALOS] ** Skipping JRuby-only specs" unless running_with_jruby

  config.before(:each, :full_description => /wait for block to return true/) do
    pending "This spec failure is a red herring; akephalos waits for " \
            "javascript events implicitly, including setTimeout."
  end

  config.before(:each, :full_description => /drag and drop/) do
    pending "drag and drop is not supported yet"
  end

  config.filter_run_excluding(:platform => lambda { |value|
    return true if value == :jruby && !running_with_jruby
  })                                     
end

require File.join(spec_dir,"spec_helper")
require "support/application"