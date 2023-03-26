class BaseFactory
  class << self
    def described_class
      raise NotImplementedError, 'must be implemented in a child class'
    end

    def create(params = {})
      new(params).create
    end

    def build(params = {})
      new(params).build
    end

    private

    def options(_params)
      raise NotImplementedError, 'must be implemented in a child class'
    end
  end

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def create
    self.class.described_class.create!(options(params))
  end

  def build
    self.class.described_class.new(options(params))
  end

  private

  def options(_params)
    raise NotImplementedError, 'must be implemented in a child class'
  end
end
