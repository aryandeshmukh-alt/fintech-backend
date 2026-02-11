# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: "_fintech_backend_session",
  same_site: :lax,
  secure: Rails.env.production?
<<<<<<< HEAD
# secure: true
=======

# SWAGGER TESTING (Use these ONLY if you need to test sessions from online Swagger Editor)
# Rails.application.config.session_store :cookie_store, 
#   key: '_fintech_backend_session',
#   same_site: :none,
#   secure: true
>>>>>>> 81fae4db0ce46f56c9a8f9fedd2645dccd561bd1
