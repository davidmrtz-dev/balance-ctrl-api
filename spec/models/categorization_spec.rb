require 'rails_helper'

RSpec.describe Categorization, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:transaction_record) }
    it { is_expected.to belong_to(:category) }
  end
end
