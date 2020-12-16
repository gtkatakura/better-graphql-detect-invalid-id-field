# frozen_string_literal: true
RSpec.describe(BetterGraphQL) do
  describe '.VERSION' do
    it 'returns version number' do
      expect(BetterGraphQL::VERSION).not_to(be(nil))
    end
  end
end
