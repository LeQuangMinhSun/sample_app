require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsTutorial
  class Application < Rails::Application
    config.load_defaults 7.0
    config.active_storage.variant_processor = :mini_magick
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml,js}")]
    config.i18n.available_locales = [:vi, :en]
    config.i18n.default_locale = :en
  end
end
