# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-ogl'

  app.frameworks << 'OpenGLES'
  app.frameworks << 'QuartzCore'
  app.frameworks << 'GLKit'

  app.entitlements['get-task-allow'] = true

  app.codesign_certificate = ENV["RUBY_MOTION_CODESIGN_CERTIFICATE"]
  app.provisioning_profile = ENV["RUBY_MOTION_PROVISIONING_PROFILE"]
end