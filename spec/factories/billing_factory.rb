class BillingFactory < BaseFactory
  def self.described_class
    Billing
  end

  private

  def options(params)
    {
      user: params.fetch(:user, nil),
      name: params.fetch(:name, 'Billing Name'),
      state_date: params.fetch(:state_date, Time.zone.now),
      billing_type: params.fetch(:billing_type, :credit)
    }
  end
end