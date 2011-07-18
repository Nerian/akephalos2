require 'spec_helper'

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, Application)
    end

    it "should ok confirm" do
      message = @session.driver.confirm_dialog do
        @session.visit('/confirm_test')
      end

      node = @session.find(:css, "p#test")
      node.text.should == "Confirmed"

      # If desired, assert the message was what we expected
      message.should == 'Are you sure?'
    end

    it "should cancel confirm" do
      @session.driver.confirm_dialog(false) do
        @session.visit('/confirm_test')
      end

      node = @session.find(:css, "p#test")
      node.text.should == "Cancelled"
    end
  end
end

