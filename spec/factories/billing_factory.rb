class BillingFactory < BaseFactory
  def self.described_class
    Billing
  end

  private

  def options(params)
    {
      user: params.fetch(:user, nil),
      name: params.fetch(:name, 'Billing Name'),
      cycle_end_date: params.fetch(:cycle_end_date, Time.zone.now),
      payment_due_date: params.fetch(:payment_due_date, Time.zone.now),
      billing_type: params.fetch(:billing_type, :credit)
    }
  end
end
