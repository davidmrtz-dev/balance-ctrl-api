require 'rails_helper'

RSpec.describe Outcome, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:purchase_date).of_type(:datetime) }
  end

  describe 'validations' do
    it { should_not allow_value(:monthly).for(:frequency).on(:create) }
    it { should allow_value(Time.zone.today).for(:purchase_date).on(:create) }
  end
end
