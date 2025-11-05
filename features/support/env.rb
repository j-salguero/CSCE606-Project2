# Minimal, Rails 7/8 friendly
require 'cucumber/rails'

# Fast tests: transactions (we're not using a JS driver here)
Cucumber::Rails::Database.javascript_strategy = :transaction

# Quiet server output (optional)
begin
  require 'capybara/rails'
  require 'capybara/puma'
  Capybara.server = :puma
rescue LoadError
  # fine
end

# Fixtures path only if supported (Rails 8 removed fixture_path=)
if defined?(ActionDispatch::IntegrationTest) &&
   ActionDispatch::IntegrationTest.respond_to?(:fixture_path=)
  ActionDispatch::IntegrationTest.fixture_path = "#{Rails.root}/spec/fixtures"
end
