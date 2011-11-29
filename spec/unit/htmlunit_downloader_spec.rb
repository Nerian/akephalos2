require_relative "../../lib/akephalos/htmlunit_downloader"

unless ENV['TRAVIS']
  describe "Download HTMLUnit" do
  
    before(:each) do
      `rm -rf .akephalos`
      HtmlUnit.stub(:download).with("2.9").and_return(true)
      HtmlUnit.stub(:remove_cache).with("2.9").and_return(true)
      HtmlUnit.stub(:unzip).with("2.9").and_return(true)
    end
  
    it "should creates .akephalos folder" do
      HtmlUnit.download_htmlunit("2.9")
      File.exists?(".akephalos").should == true
    end
  
    it "should creates folder for that version" do
      HtmlUnit.download_htmlunit("2.9")
      File.exists?(".akephalos/2.9").should == true
    end
  
    it "should download that version" do
      HtmlUnit.should_receive(:download).with("2.9").and_return(true)
      HtmlUnit.download_htmlunit("2.9")
    end
  
    it "should unzip it" do
      HtmlUnit.should_receive(:unzip).with("2.9").and_return(true)
      HtmlUnit.download_htmlunit("2.9")
    end
  
    it "should remove the cache file" do
      HtmlUnit.should_receive(:remove_cache).with("2.9").and_return(true)
      HtmlUnit.download_htmlunit("2.9")
    end
  
    it "should just use it if already present" do
      HtmlUnit.stub(:version_exist?).and_return(true)
      HtmlUnit.should_not_receive(:remove_cache)
      HtmlUnit.download_htmlunit("2.9")
    end
  end

  describe "Integration test" do
    it "should set up htmlunit 2.9" do
      `rm -rf .akephalos`
      HtmlUnit.download_htmlunit("2.9")
      File.exist?(".akephalos/2.9/htmlunit-2.9.jar").should == true
    end
  
    it "should set up htmlunit 2.10" do
      `rm -rf .akephalos`
      HtmlUnit.download_htmlunit("2.10")
      File.exist?(".akephalos/2.10/htmlunit-2.10-SNAPSHOT.jar").should == true
    end
  end
end