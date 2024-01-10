class User < ApplicationRecord
  devise :database_authenticatable, :recoverable # , :trackable, :rememberable

  include DeviseTokenAuth::Concerns::User

  has_many :balances, dependent: :destroy
  has_many :billings, dependent: :destroy

  def current_balance
    balances.first
  end
end
