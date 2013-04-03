require "resizor"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

Resizor.configure do |config|
  config.access_key = "test-access"
  config.secret_key = "test-secret"
end

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
