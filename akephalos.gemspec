# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "akephalos/version"

Gem::Specification.new do |s|
  s.name              = "akephalos2"
  s.version           = Akephalos::VERSION
  s.platform          = ENV["PLATFORM"] || "ruby"
  s.authors           = ["Bernerd Schaefer", "Gonzalo Rodríguez-Baltanás Díaz"]
  s.email             = ["bj.schaefer@gmail.com", "siotopo@gmail.com"]
  s.homepage          = "https://github.com/Nerian/akephalos2"
  s.summary           = "Headless Browser for Integration Testing with Capybara"
  s.description       = s.summary

  s.add_runtime_dependency "capybara"
  s.add_runtime_dependency "rake"
  
  if RUBY_PLATFORM != "java" && ENV["PLATFORM"] != "java"
    s.add_runtime_dependency "jruby-jars"
  end
  
  if RUBY_PLATFORM =~ /mingw32/
    s.add_runtime_dependency "win32-process"
  end

  s.add_development_dependency "sinatra"
  s.add_development_dependency "rspec"

  s.files         = Dir.glob("lib/**/*.rb") + %w(README.md MIT_LICENSE)
  s.require_paths = %w(lib vendor)
  s.executables   = %w(akephalos)
end
