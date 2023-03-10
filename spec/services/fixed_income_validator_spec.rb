require 'rails_helper'

describe FixedIncomeValidator do
  describe '.for' do
    it 'return test text' do
      expect(described_class.for({})).to eq 'validate for fixed income'
    end
  end
end