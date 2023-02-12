class PaymentFactory < BaseFactory
  def self.described_class
    Payment
  end

  private

  def options(params)
    {
      paymentable: params.fetch(:paymentable, nil),
      amount: params.fetch(:amount, 5_000),
      status: params.fetch(:status, :pending)
    }
  end
end