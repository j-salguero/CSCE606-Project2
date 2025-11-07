require 'cucumber/rails'

Cucumber::Rails::Database.javascript_strategy = :transaction

begin
  require 'capybara/rails'
  require 'capybara/puma'
  Capybara.server = :puma
rescue LoadError
end

if defined?(ActionDispatch::IntegrationTest) &&
   ActionDispatch::IntegrationTest.respond_to?(:fixture_path=)
  ActionDispatch::IntegrationTest.fixture_path = "#{Rails.root}/spec/fixtures"
end
