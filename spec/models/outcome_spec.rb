require 'rails_helper'

RSpec.describe Outcome, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
  end
end
