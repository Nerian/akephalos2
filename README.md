# Akephalos
Akephalos is a full-stack headless browser for integration testing with
Capybara. It is built on top of [HtmlUnit](http://htmlunit.sourceforge.net),
a GUI-less browser for the Java platform, but can be run on both JRuby and
MRI with no need for JRuby to be installed on the system.

## Installation

    gem install akephalos

## Setup

Configuring akephalos is as simple as requiring it and setting Capybara's
javascript driver:

    require 'akephalos'
    Capybara.javascript_driver = :akephalos

## Basic Usage

Akephalos provides a driver for Capybara, so using Akephalos is no
different than using Selenium or Rack::Test. For a full usage guide, check
out Capybara's DSL [documentation](http://github.com/jnicklas/capybara). It
makes no assumptions about the testing framework being used, and works with
RSpec, Cucumber, and Test::Unit.

Here's some sample RSpec code:

    describe "Home Page" do
      before { visit "/" }
      context "searching" do
        before do
          fill_in "Search", :with => "akephalos"
          click_button "Go"
        end
        it "returns results" { page.should have_css("#results") }
        it "includes the search term" { page.should have_content("akephalos") }
      end
    end

## Configuration

There are now a few configuration options available through Capybara's new
`register_driver` API.

### Using a different browser

HtmlUnit supports a few browser implementations, and you can choose which
browser you would like to use through Akephalos. By default, Akephalos uses
Firefox 3.6.

    Capybara.register_driver :akephalos do |app|
      # available options:
      #   :ie6, :ie7, :ie8, :firefox_3, :firefox_3_6
      Capybara::Driver::Akephalos.new(app, :browser => :ie8)
    end

### Ignoring javascript errors

By default HtmlUnit (and Akephalos) will raise an exception when an error
is encountered in javascript files. This is generally desireable, except
that certain libraries aren't supported by HtmlUnit. If possible, it's
best to keep the default behavior, and use Filters (see below) to mock
offending libraries. If needed, however, you can configure Akephalos to
ignore javascript errors.

    Capybara.register_driver :akephalos do |app|
      Capybara::Driver::Akephalos.new(app, :validate_scripts => false)
    end   

### Setting the HtmlUnit log level

By default it uses the 'fatal' level. You can change that like this:

	Capybara.register_driver :akephalos do |app|  
		# available options 
		# "trace", "debug", "info", "warn", "error", or "fatal"
		Capybara::Driver::Akephalos.new(app, :htmlunit_log_level => 'fatal')
	end

## More

* [bin/akephalos](http://bernerdschaefer.github.com/akephalos/akephalos-bin.html)
  allows you to start an interactive shell or DRb server, as well as perform
  other maintenance features.

* [Filters](http://bernerdschaefer.github.com/akephalos/filters.html) allows
  you to declare mock responses for external resources and services requested
  by the browser.

## Resources

* [API Documentation](http://bernerdschaefer.github.com/akephalos/api)
* [Source code](http://github.com/bernerdschaefer/akephalos) and
  [issues](http://github.com/bernerdschaefer/akephalos/issues) are hosted on
  github.
