require "pliny/tasks"

task :worker do
  require_relative './lib/application'
  Toygun::Worker.new.start
end

task :clock do
  require_relative './lib/application'
  Toygun::Clock.new.start
end
