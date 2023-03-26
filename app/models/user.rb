class User < ApplicationRecord
  devise :database_authenticatable, :recoverable # , :trackable, :rememberable

  include DeviseTokenAuth::Concerns::User

  has_one :balance, dependent: :destroy

  delegate :id, to: :balance, prefix: true
end
