require "pathname"
require "java"

HtmlUnit.download_htmlunit(ENV["htmlunit_version"])

Dir["#{Dir.pwd}/.akephalos/#{ENV['htmlunit_version']}/*.jar"].each {|file| require file;}

java.lang.System.setProperty("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.SimpleLog")
java.lang.System.setProperty("org.apache.commons.logging.simplelog.defaultlog", "fatal")
java.lang.System.setProperty("org.apache.commons.logging.simplelog.showdatetime", "true")

# Container module for com.gargoylesoftware.htmlunit namespace.
module HtmlUnit
  java_import "com.gargoylesoftware.htmlunit.BrowserVersion"
  java_import "com.gargoylesoftware.htmlunit.History"
  java_import "com.gargoylesoftware.htmlunit.HttpMethod"
  java_import 'com.gargoylesoftware.htmlunit.ConfirmHandler'
  java_import "com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController"
  java_import "com.gargoylesoftware.htmlunit.SilentCssErrorHandler"
  java_import "com.gargoylesoftware.htmlunit.WebClient"
  java_import "com.gargoylesoftware.htmlunit.WebResponseData"
  java_import "com.gargoylesoftware.htmlunit.WebResponse"
  java_import "com.gargoylesoftware.htmlunit.WaitingRefreshHandler"

  # Container module for com.gargoylesoftware.htmlunit.util namespace.
  module Util
    java_import "com.gargoylesoftware.htmlunit.util.NameValuePair"
    java_import "com.gargoylesoftware.htmlunit.util.WebConnectionWrapper"
  end

  # Disable history tracking
  History.field_reader :ignoreNewPages_
end
