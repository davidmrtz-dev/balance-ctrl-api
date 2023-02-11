require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:outcome) }
  end

  # describe 'validations' do

  # end
end
