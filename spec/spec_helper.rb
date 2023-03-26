RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec::Matchers.define :be_like_json_of do |serializable_hash|
  match do |actual|
    @actual = JSON.parse(actual)
    values_match? serializable_hash.as_json, @actual
  end
  diffable
end
