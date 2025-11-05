# Cucumber coverage focused on controllers/models only
if ENV['COVERAGE'] != 'false'
  require 'simplecov'
  SimpleCov.start do
    enable_coverage :branch
    track_files 'app/{controllers,models}/**/*.rb'

    add_filter '/app/helpers/'
    add_filter '/app/views/'
    add_filter '/app/services/'
    add_filter '/app/jobs/'
    add_filter '/app/mailers/'
    add_filter '/app/channels/'
    add_filter '/app/assets/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/lib/'
    add_filter '/bin/'
    add_filter '/spec/'
    add_filter '/features/'

    minimum_coverage 90
  end
  SimpleCov.command_name 'cucumber'
  SimpleCov.coverage_dir 'coverage/cucumber'
end
