module Pagination
  extend ActiveSupport::Concern

  private

  def paginate(records, limit:, offset:)
    records
      .limit(limit || 10)
      .offest(offset || 0)
  end
end