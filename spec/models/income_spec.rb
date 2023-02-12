require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should allow_value(:monthly).for(:frequency).on(:create) }
    it { should_not allow_value(Time.zone.today).for(:purchase_date).on(:create) }
  end
end
