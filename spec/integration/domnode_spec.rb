require 'spec_helper'

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, Application)
    end

    it "Element#text will return browser formatted text" do
      @session.visit('/domnode_test')

      @session.find(:css, "p#original_html").text.should       == "original html"
      @session.find(:css, "p#horizontal_tab").text.should      == "original html"
      @session.find(:css, "p#line_feed").text.should           == "original html"
      @session.find(:css, "p#carriage_return").text.should     == "original html"
      @session.find(:css, "p#non_breaking_space").text.should  == " original  html "
    end

    it "Element#native#text_content will return raw text including whitespace" do
      @session.visit('/domnode_test')

      @session.find(:css, "p#original_html").native.text_content.should      == "original html"
      @session.find(:css, "p#horizontal_tab").native.text_content.should     == "\toriginal\t html\t"
      @session.find(:css, "p#line_feed").native.text_content.should          == "\noriginal\n html\n"
      @session.find(:css, "p#carriage_return").native.text_content.should    == "\roriginal\r html\r"
      @session.find(:css, "p#non_breaking_space").native.text_content.should ==  "\302\240original\302\240 html\302\240"
    end

    it "Element#native#xml will return the current DOM from the node as xml" do
      @session.visit('/xml_vs_source_test')
      @session.find(:css, "p#javascript_modified").native.xml.should ==   "<p id=\"javascript_modified\">\n  javascript modified after\n</p>\n"
    end

    it "Session#source will return the original html with the DOM pre-javascript" do
      @session.visit('/xml_vs_source_test')
      @session.source.should == "  <body>\n    <p id=\"javascript_modified\">javascript modified</p>\n    <script type=\"text/javascript\">\n        document.getElementById(\"javascript_modified\").innerHTML = 'javascript modified after';\n    </script>\n  </body>\n"
    end
  end
end