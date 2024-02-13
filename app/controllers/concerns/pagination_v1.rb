module PaginationV1
  extend ActiveSupport::Concern

  private

  def apply_pagination(records, page:, page_size:)
    records
      .limit(page_size)
      .offset((page - 1) * page_size)
  end
end
