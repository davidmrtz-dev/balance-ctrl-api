require 'rails_helper'

RSpec.describe FinanceActive, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:income_frequency).with_values(%i[weekly biweekly monthly]) }
    it { should define_enum_for(:active_type).with_values(%i[fixed current]) }
  end
end
