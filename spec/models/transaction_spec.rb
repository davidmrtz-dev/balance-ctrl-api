require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { should define_enum_for(:transaction_type).with_values(%i[current fixed]) }
    it { should have_db_column(:purchase_date).of_type(:datetime) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end
end
