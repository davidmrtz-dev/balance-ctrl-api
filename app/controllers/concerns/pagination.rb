module Pagination
  extend ActiveSupport::Concern

  private

  def paginate(records, limit:, offset:)
    records
      .limit(limit || 10)
      .offset(offset || 0)
  end
end