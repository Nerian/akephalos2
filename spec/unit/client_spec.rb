require 'spec_helper'

describe Akephalos::Client, :platform => :jruby do

  context "browser version" do

    it "defaults to Firefox 3.6" do
      client = Akephalos::Client.new
      client.browser_version.should ==
        HtmlUnit::BrowserVersion::FIREFOX_3_6
    end

    it "can be configured in the initializer" do
      client = Akephalos::Client.new(:browser => :ie6)
      client.browser_version.should ==
        HtmlUnit::BrowserVersion::INTERNET_EXPLORER_6
    end

    it "configures HtmlUnit" do
      client = Akephalos::Client.new(:browser => :ie7)

      client.send(:client).getBrowserVersion.should ==
        HtmlUnit::BrowserVersion::INTERNET_EXPLORER_7
    end

  end 
  
  context "HTMLUnit log level" do   
    
    it "defaults to fatal" do
      client = Akephalos::Client.new
      client.htmlunit_log_level.should == 'fatal'
    end
    
    context "#can be configured to" do
      
      ["trace", "debug", "info", "warn", "error", "fatal"].each do |log_level|
        it "#{log_level}" do
          client = Akephalos::Client.new(:htmlunit_log_level => log_level)
          client.htmlunit_log_level.should == log_level
        end
        
      end
      
    end
                    
  end

  context "script validation" do

    it "defaults to raising errors on script execution" do
      Akephalos::Client.new.validate_scripts?.should be_true
    end

    it "can be configured not to raise errors on script execution" do
      Akephalos::Client.new(
        :validate_scripts => false
      ).validate_scripts?.should be_false
    end

    it "configures HtmlUnit" do
      client = Akephalos::Client.new(:validate_scripts => false)

      client.send(:client).isThrowExceptionOnScriptError.should be_false
    end

  end

  context "using insecure ssl verification" do

    it "defaults to not ignoring insecure ssl certificates" do
      Akephalos::Client.new.use_insecure_ssl?.should be_false
    end

    it "can be configured to ignore insecure ssl certificates" do
      Akephalos::Client.new(
        :use_insecure_ssl => true
      ).use_insecure_ssl?.should be_true
    end
    
    it "configures HtmlUnit" do
      pending "how do we check this?"
    end

  end
  
end
