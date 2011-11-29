# encoding: utf-8
require 'spec_helper'

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, Application)
    end
    
    it "does something" do
      @session.visit '/js_click'
      @session.fill_in 'Number 1', :with => 5
      @session.fill_in 'Number 2', :with => 6
      @session.click_button 'Answer'
      @session.should have_content('11')
      
    end
    
  end
end