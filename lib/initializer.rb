module Initializer
  def self.run
    require_config
    require_initializers
    require_lib
  end

  def self.require_config
    require_relative "../config/config"
  end

  def self.require_lib
    require! %w(
      lib/toygun
      lib/resources/*
      lib/resources/**/*
      lib/endpoints/base
      lib/endpoints/**/*
      lib/routes
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
