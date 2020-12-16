# frozen_string_literal: true
module BetterGraphQL
  class DetectInvalidIdField
    def self.use(schema)
      tracer = new
      schema.tracer(tracer)
    end

    def initialize
      @cache = {}
    end

    def trace(key, data)
      @cache = {} if key == 'parse'

      return yield if key != 'execute_field'

      yield.tap do |resolved_value|
        next unless comparable?(resolved_value)

        if data[:context]
          parent_type = data[:context].parent_type
          field = data[:context].field
          path = data[:context].path
        else
          parent_type = data[:owner]
          field = data[:field]
          path = data[:path]
        end

        cache_by_type = cache[parent_type] ||= {}
        nodes_by_path = cache_by_type[:nodes_by_path] ||= {}
        nodes_by_id = cache_by_type[:nodes_by_id] ||= {}

        field_name = field.name.to_sym
        parent_path = path[0..-2]

        resolving_object = nodes_by_path[parent_path] ||= {
          __metadata__: { parent_path: parent_path },
        }

        resolving_object[field_name] = resolved_value

        if field_name == :id
          nodes_by_id[resolved_value] ||= []
          nodes_by_id[resolved_value] << resolving_object
          next
        end

        if resolving_object.key?(:id)
          all_nodes_with_same_id = nodes_by_id[resolving_object[:id]]

          other_nodes_with_same_id = all_nodes_with_same_id - [resolving_object]

          other_nodes_with_same_id.each do |another_node|
            next unless another_node[field_name] != resolved_value
            raise StandardError,
              "The field #{parent_type.graphql_name}#id must be unique across the graph." \
              ' You have two nodes representing the same object in the graph, but they are returning different values for the same field.' \
              " #{parent_type.graphql_name}#id = #{resolving_object[:id]}." \
              " Divergence: #{(another_node[:__metadata__][:parent_path] + [field_name]).join('.')} = #{another_node[field_name].to_json} and #{path.join('.')} = #{resolved_value.to_json}"
          end
        end
      end
    end

    private

    attr_reader :cache

    def comparable?(value)
      value.is_a?(Numeric) ||
        value.is_a?(String) ||
        value.is_a?(Date) ||
        value.is_a?(DateTime) ||
        value.is_a?(Time) ||
        value.is_a?(TrueClass) ||
        value.is_a?(FalseClass) ||
        value.is_a?(NilClass) ||
        value.is_a?(Hash)
    end
  end
end
