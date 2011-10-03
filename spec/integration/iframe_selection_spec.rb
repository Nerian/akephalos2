require 'spec_helper'

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, Application)
    end

    context "iframe selection" do
      it "should select iframe by index" do
        @session.visit('/iframe_selection_test')
        @session.within_frame(0) do
          @session.should have_content("Frame 1")
          @session.should_not have_content("Frame 2")
        end
        @session.within_frame(1) do
          @session.should have_content("Frame 2")
          @session.should_not have_content("Frame 1")
        end
      end

      it "should return the usual exception when selecting a crazy index" do
        @session.visit('/iframe_selection_test')
        expect { @session.within_frame(9999) {} }.should raise_error(Capybara::ElementNotFound)
      end

      it "should select iframe by id" do
        @session.visit('/iframe_selection_test')
        @session.within_frame('third') do
          @session.should have_content("Frame 3")
          @session.should_not have_content("Frame 2")
          @session.should_not have_content("Frame 1")
        end
      end      
    end

  end
end

