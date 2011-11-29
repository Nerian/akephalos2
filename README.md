# Important Notice

This repo has rewritten its history and as such is not compatible with the main Akephalos repo.

You can get the unaltered – before history rewrite – pristine copy at: [https://github.com/Nerian/akephalos](https://github.com/Nerian/akephalos)

Further development will be done here:
[https://github.com/Nerian/akephalos2](https://github.com/Nerian/akephalos2)

The reason why its history was rewrote was to remove .jar vendor files that were making its size huge.


# Akephalos

Akephalos is a full-stack headless browser for integration testing with
[Capybara](https://github.com/jnicklas/capybara). It is built on top of [HtmlUnit](http://htmlunit.sourceforge.net),
a GUI-less browser for the Java platform, but can be run on both JRuby and
MRI with no need for JRuby to be installed on the system.


## Installation

``` ruby
gem install akephalos2
```

Or

``` ruby
gem 'akephalos2', :require => 'akephalos'
```

Or (for the current master branch)

``` ruby
gem 'akephalos2', :git => 'git://github.com/Nerian/akephalos2.git'
```

Akephalos creates a `.akephalos` folder where it stores HTMLUnit binaries. You should set Git to ignore that folder.

```
git ignore .akephalos
```

# Questions, bugs, etc:

We use GitHub issues:

[https://github.com/Nerian/akephalos2/issues](https://github.com/Nerian/akephalos2/issues)

# Development

<a href='http://travis-ci.org/#!/Nerian/akephalos2'>
	<img src="https://secure.travis-ci.org/Nerian/akephalos2.png?branch=master&amp;.png"/>
</a>

``` bash
git clone https://github.com/Nerian/akephalos2
```

Also, we have a .rvmrc file already cooked:

``` bash
cp .rvmrc.example .rvmrc
```

## Setup

Configuring akephalos is as simple as requiring it and setting Capybara's
javascript driver:

``` ruby
require 'akephalos'
Capybara.javascript_driver = :akephalos
```

## Basic Usage

Akephalos provides a driver for Capybara, so using Akephalos is no
different than using Selenium or Rack::Test. For a full usage guide, check
out Capybara's DSL [documentation](http://github.com/jnicklas/capybara). It
makes no assumptions about the testing framework being used, and works with
RSpec, Cucumber, and Test::Unit.

Here's some sample RSpec code:

``` ruby
# encoding: utf-8

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
```

### Encoding

Akephalos uses UTF-8 encoding by default. You may need to add `# encoding: utf-8` at the first line of your test. This behavior is the default using JRuby in 1.9 mode, but you can use JRuby in 1.8 mode by setting the environment variable `ENV['JRUBY_1_8']=true`. Note that Akephalos works with MRI. I refer here to the JRuby that is used internally by Akephalos.


### Frames

Capybara allows you to perform your action on a context, for example inside a div or a frame. With Akephalos you can select the frame either by id or by index.

``` html
<body>
  <p id="test">Test</p>
  <iframe id="first" src="/one_text"></iframe>
  <p id="test2">Test2</p>
  <iframe class="second" src="/two_text"></iframe>
  <p id="test3">Test3</p>
  <iframe id="third" src="/three_text"></iframe>
</body>
```

You can operate within the context of iframe `test2` with any of these calls:

``` ruby
# By ID
within_frame("test2") do
  ....
end

# By index
within_frame(1) do
  ....
end
```

## Configuration

There are now a few configuration options available through Capybara's new
`register_driver` API.

### Configure the max memory that Java Virtual Machine can use

The max memory that the JVM is going to use can be set using an environment variable in your spec_helper or .bashrc file.

``` ruby
ENV['akephalos_jvm_max_memory']
```

The default value is 128 MB.

If you use Akephalos's bin the parameter `-m [memory]` sets the max memory for the JVM.

``` bash
$ akephalos -m 670
```

### Configure the version of HTMLUnit

The Htmlunit version is configured with a environmental variable named `htmlunit_version`. The possible versions are listed at [here](http://sourceforge.net/projects/htmlunit/files/htmlunit/)

```
ENV["htmlunit_version"] = "2.10"  # Development Snapshots
ENV["htmlunit_version"] = "2.9"
ENV["htmlunit_version"] = "2.8"
ENV["htmlunit_version"] = "2.7"
```

It defaults to HtmlUnit 2.9. You can manually download or copy your own version to .akephalos/:version and use it with `ENV["htmlunit_version"] = "version"`

### Using a different browser

HtmlUnit supports a few browser implementations, and you can choose which
browser you would like to use through Akephalos. By default, Akephalos uses
Firefox 3.6.

``` ruby
Capybara.register_driver :akephalos do |app|
  #  available options:
  #  :ie6, :ie7, :ie8, :firefox_3_6
  Capybara::Driver::Akephalos.new(app, :browser => :ie8)
end
```


### Using a Proxy Server

``` ruby
Capybara.register_driver :akephalos do |app|
  Capybara::Driver::Akephalos.new(app, :http_proxy => 'myproxy.com', :http_proxy_port => 8080)
end
```


### Ignoring javascript errors

By default HtmlUnit (and Akephalos) will raise an exception when an error
is encountered in javascript files. This is generally desirable, except
that certain libraries aren't supported by HtmlUnit. If possible, it's
best to keep the default behaviour, and use Filters (see below) to mock
offending libraries. If needed, however, you can configure Akephalos to
ignore javascript errors.

``` ruby
Capybara.register_driver :akephalos do |app|
  Capybara::Driver::Akephalos.new(app, :validate_scripts => false)
end
```


### Setting the HtmlUnit log level

By default it uses the 'fatal' level. You can change that like this:

``` ruby
Capybara.register_driver :akephalos do |app|
  # available options
  # "trace", "debug", "info", "warn", "error", or "fatal"
  Capybara::Driver::Akephalos.new(app, :htmlunit_log_level => 'fatal')
end
```


### Running Akephalos with Spork

``` ruby
Spork.prefork do
  ...
  Akephalos::RemoteClient.manager
end

Spork.each_run do
  ...
  Thread.current['DRb'] = { 'server' => DRb::DRbServer.new }
end
```


More info at : [sporking-with-akephalos](http://spacevatican.org/2011/7/3/sporking-with-akephalos)

### Filters

Akephalos allows you to filter requests originating from the browser and return mock responses. This will let you easily filter requests for external resources when running your tests, such as Facebook's API and Google Analytics.

Configuring filters in Akephalos should be familiar to anyone who has used FakeWeb or a similar library. The simplest filter requires only an HTTP method (:get, :post, :put, :delete, :any) and a string or regex to match against.

``` ruby
Akephalos.filter(:get, "http://www.google.com")
Akephalos.filter(:any, %r{^http://(api\.)?twitter\.com/.*$})
```


By default, all filtered requests will return an empty body with a 200 status code. You can change this by passing additional options to your filter call.

``` ruby
Akephalos.filter(:get, "http://google.com/missing",
  :status => 404, :body => "... <h1>Not Found</h1> ...")

Akephalos.filter(:post, "http://my-api.com/resource.xml",
  :status => 201, :headers => {
    "Content-Type" => "application/xml",
    "Location" => "http://my-api.com/resources/1.xml" },
    :body => {:id => 100}.to_xml)
```


And that's really all there is to it! It should be fairly trivial to set up filters for the external resources you need to fake. For reference, however, here's what we ended up using for our external sources.

#### Example: Google Maps

Google Analytics code is passively applied based on HTML comments, so simply returning an empty response body is enough to disable it without errors.

``` ruby
Akephalos.filter(:get, "http://www.google-analytics.com/ga.js",
  :headers => {"Content-Type" => "application/javascript"})
```


Google Maps requires the most extensive amount of API definitions of the three, but these few lines cover everything we've encountered so far.

``` ruby
Akephalos.filter(:get, "http://maps.google.com/maps/api/js?sensor=false",
  :headers => {"Content-Type" => "application/javascript"},
  :body => "window.google = {
    maps: {
      LatLng: function(){},
      Map: function(){},
      Marker: function(){},
      MapTypeId: {ROADMAP:1}
    }
   };")
```


#### Example: Facebook Connect

Facebook Connect

When you enable Facebook Connect on your page, the FeatureLoader is requested, and then additional resources are loaded when you call FB_RequireFeatures. We can therefore return an empty function from our filter to disable all Facebook Connect code.

``` ruby
Akephalos.filter(:get,
  "http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php",
  :headers => {"Content-Type" => "application/javascript"},
  :body => "window.FB_RequireFeatures = function() {};")
```


### Akephalos' Interactive mode

#### bin/akephalos

The bundled akephalos binary provides a command line interface to a few useful features.

#### akephalos --interactive

Running Akephalos in interactive mode gives you an IRB context for interacting with your site just as you would in your tests:

``` ruby
$ akephalos --interactive
  ->  Capybara.app_host # => "http://localhost:3000"
  ->  page.visit "/"
  ->  page.fill_in "Search", :with => "akephalos"
  ->  page.click_button "Go"
  ->  page.has_css?("#search_results") # => true
```


#### akephalos --use-htmlunit-snapshot

This will instruct Akephalos to use the latest development snapshot of HtmlUnit as found on it's Cruise Control server. HtmlUnit and its dependencies will be unpacked into vendor/htmlunit in the current working directory.

This is what the output looks like:

``` ruby
$ akephalos --use-htmlunit-snapshot

Downloading latest snapshot... done
Extracting dependencies... done
========================================
The latest HtmlUnit snapshot has been extracted to vendor/htmlunit!
Once HtmlUnit has been extracted, Akephalos will automatically detect
the vendored version and use it instead of the bundled version.
```


#### akephalos --server <socket_file>

Akephalos uses this command internally to start a JRuby DRb server using the provided socket file.