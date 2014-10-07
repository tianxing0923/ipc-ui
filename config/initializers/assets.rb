# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( login.js login.css )
Rails.application.config.assets.precompile += %w( respond.min.js excanvas.min.js )
Rails.application.config.assets.precompile += %w( bootstrap-ie7.css font-awesome-ie7.min.css json3.min.js )
