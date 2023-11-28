module PaginationV1
  extend ActiveSupport::Concern

  private

  def apply_pagination(records, page:, page_size:)
    page = page.to_i
    page_size = page_size.to_i
    offset = (page - 1) * page_size

    records
      .limit(page_size)
      .offset(offset)
  end
end
