require 'rails_helper'

RSpec.describe Balance, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:finance_obligations) }
    it { is_expected.to have_many(:finance_actives) }
  end
end
