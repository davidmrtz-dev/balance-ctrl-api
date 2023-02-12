require 'rails_helper'

RSpec.describe Outcome, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:purchase_date).of_type(:datetime) }
  end
end
