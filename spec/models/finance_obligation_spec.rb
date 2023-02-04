require 'rails_helper'

RSpec.describe FinanceObligation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:obligation_type).with_values(%i[fixed current]) }
    it { should define_enum_for(:status).with_values(%i[active inactive]) }
  end
end
