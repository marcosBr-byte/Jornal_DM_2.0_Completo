Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.object_src :none
    policy.frame_ancestors :none
    policy.form_action :self
    policy.script_src :self
    # Trix uses inline style attributes for editing; scripts still require a nonce.
    policy.style_src :self, :unsafe_inline, "https://fonts.googleapis.com"
    policy.font_src :self, "https://fonts.gstatic.com"
    policy.img_src :self, :data
    policy.connect_src :self
    policy.upgrade_insecure_requests if Rails.env.production?
  end
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end
