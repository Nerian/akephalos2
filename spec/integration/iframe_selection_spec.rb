require 'spec_helper'

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, Application)
    end

    context "iframe selection" do
      it "should select iframe by index" do
      	@session.visit('/iframe_selection_test')
        @session.within_frame(1) do
        	@session.should have_content("derp")
        end
      end
      
	  it "should select iframe by id" do
	    @session.visit('/iframe_selection_test')
        @session.within_frame('beefcake') do
			@session.should have_content("tasty and delicious")
			@session.should_not have_content("derp")
        end
      end      
    end

  end
end

