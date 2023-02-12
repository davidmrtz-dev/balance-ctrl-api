require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end
end
