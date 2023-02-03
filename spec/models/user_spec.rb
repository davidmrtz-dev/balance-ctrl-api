require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:balance).dependent(:destroy) }
  end
end