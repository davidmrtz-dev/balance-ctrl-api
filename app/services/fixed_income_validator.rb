class FixedIncomeValidator < ApplicationService
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def process
    'validate for fixed income'
  end
end