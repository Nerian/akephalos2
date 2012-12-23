# **Akephalos** is a cross-platform Ruby interface for *HtmlUnit*, a headless
# browser for the Java platform.
#
# The only requirement is that a Java runtime is available.
#
require 'java' if RUBY_PLATFORM == 'java'

module Akephalos
  BIN_DIR = Pathname(__FILE__).expand_path.dirname.parent + 'bin'
  ENV['htmlunit_version'] ||= "2.9"
end

require 'akephalos/htmlunit_downloader'
require 'akephalos/client'
require 'capybara'
require 'akephalos/capybara'
