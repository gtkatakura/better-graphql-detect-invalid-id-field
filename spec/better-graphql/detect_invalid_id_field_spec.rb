# frozen_string_literal: true
require 'graphql'

RSpec.describe(BetterGraphQL::DetectInvalidIdField) do
  User = Struct.new(:id, :name)

  let(:schema) do
    type_defs = <<-GRAPHQL
      type Query {
        users: [User!]!
      }

      type User {
        id: ID!
        name: String!
      }
    GRAPHQL

    GraphQL::Schema.from_definition(type_defs, default_resolve: resolvers, interpreter: false)
  end

  let(:schema_using_better_graphql) do
    Class.new(schema) do
      use BetterGraphQL::DetectInvalidIdField
    end
  end

  context 'when another field has divergence for same id' do
    let(:resolvers) do
      {
        'Query' => {
          'users' => proc do
            [User.new(1, 'John'), User.new(1, 'Jane')]
          end,
        },
      }
    end

    it 'raises error with detailed information about the divergence' do
      expect { schema_using_better_graphql.execute('query { users { id name } } ') }.to(raise_error(
        'The field User#id must be unique across the graph.' \
        ' You have two nodes representing the same object in the graph,' \
        ' but they are returning different values for the same field.' \
        ' User#id = 1. Divergence: users.0.name = "John" and users.1.name = "Jane"'
      ))
    end

    context 'and it is a normal schema' do
      class UserType < GraphQL::Schema::Object
        field :id, ID, null: false
        field :name, ID, null: false
      end

      class QueryType < GraphQL::Schema::Object
        field :users, [UserType], null: false

        def users
          [User.new(1, 'John'), User.new(1, 'Jane')]
        end
      end

      class GraphQLSchema < GraphQL::Schema
        query(QueryType)

        use BetterGraphQL::DetectInvalidIdField
      end

      it 'raises error with detailed information about the divergence' do
        expect { GraphQLSchema.execute('query { users { id name } } ') }.to(raise_error(
          'The field User#id must be unique across the graph.' \
          ' You have two nodes representing the same object in the graph,' \
          ' but they are returning different values for the same field.' \
          ' User#id = 1. Divergence: users.0.name = "John" and users.1.name = "Jane"'
        ))
      end
    end
  end

  context "when don't have divergence" do
    let(:resolvers) do
      {
        'Query' => {
          'users' => proc do
            [User.new(1, 'John'), User.new(2, 'Jane')]
          end,
        },
      }
    end

    it 'raises error with detailed information about the divergence' do
      expect { schema_using_better_graphql.execute('query { users { id name } } ') }.not_to(raise_error)
    end
  end
end
