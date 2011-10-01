# Important Notice

This repo has rewrote its history and as such is not compatible with the main Akephalos repo. 

Further development will be done here.
 
You can get the unaltered pristine copy at: [https://github.com/Nerian/akephalos](https://github.com/Nerian/akephalos)

The reason why its history was rewrote was to remove .jar vendor files that were making its size huge.


# Akephalos        

Akephalos is a full-stack headless browser for integration testing with
Capybara. It is built on top of [HtmlUnit](http://htmlunit.sourceforge.net),
a GUI-less browser for the Java platform, but can be run on both JRuby and
MRI with no need for JRuby to be installed on the system.


## Installation
     
``` ruby
gem install akephalos2
```     

Or

``` ruby
gem 'akephalos', :git => 'git://github.com/Nerian/akephalos.git'
```

# Development

``` bash
git clone https://github.com/Nerian/akephalos2 
git submodule update --init
# optional
cp .rvmrc.example .rvmrc
```

The last line will grab the HTMLUnit jar files from [https://github.com/Nerian/html-unit-vendor](https://github.com/Nerian/html-unit-vendor)

  
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
 

## Configuration

There are now a few configuration options available through Capybara's new
`register_driver` API.    

### Configuring the max memory that Java Virtual Machine can use

The max memory that the JVM is going to use can be set using an environment variable in your spec_helper or .bashrc file.

``` ruby                                                                            
ENV['akephalos_jvm_max_memory']
```                              
  

The default value is 256 MB.

If you use akephalos's bin the parameter `-m [memory]` sets the max memory for the JVM.

``` bash
$ akephalos -m 670
``` 


### Using a different browser

HtmlUnit supports a few browser implementations, and you can choose which
browser you would like to use through Akephalos. By default, Akephalos uses
Firefox 3.6.

``` ruby
Capybara.register_driver :akephalos do |app|
	# available options:
	#   :ie6, :ie7, :ie8, :firefox_3, :firefox_3_6
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
	->	Capybara.app_host # => "http://localhost:3000"
	->	page.visit "/"
	->	page.fill_in "Search", :with => "akephalos"
	->	page.click_button "Go"
	->	page.has_css?("#search_results") # => true  
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

## Resources

* [API Documentation](http://bernerdschaefer.github.com/akephalos/api)
* [Source code](http://github.com/bernerdschaefer/akephalos) and
  [issues](http://github.com/bernerdschaefer/akephalos/issues) are hosted on
  github.
