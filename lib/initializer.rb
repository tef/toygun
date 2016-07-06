module Initializer
  def self.run
    require_config
    require_lib
    require_initializers
    require_models
  end

  def self.require_config
    require_relative "../config/config"
  end

  def self.require_lib
    require! %w(
      lib/toygun
      lib/endpoints/base
      lib/endpoints/**/*
      lib/routes
    )
  end

  def self.require_models
    require! %w(
      lib/models/**/*
      lib/subtasks
    )
  end

  def self.require_initializers
    Pliny::Utils.require_glob("#{Config.root}/config/initializers/*.rb")
  end

  def self.require!(globs)
    Array(globs).each do |f|
      Pliny::Utils.require_glob("#{Config.root}/#{f}.rb")
    end
  end
end

Initializer.run