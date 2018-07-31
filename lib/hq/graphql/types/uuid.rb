module HQ
  module GraphQL
    module Types
      class UUID < ::GraphQL::Schema::Scalar
        description "UUID"

        class << self
          def self.coerce_input(value, context)
            validate_and_return_uuid(value)
          end

          def self.coerce_result(value, context)
            validate_and_return_uuid(value)
          end

          private

          def validate_and_return_uuid(value)
            if validate_uuid(value)
              value
            else
              raise ::GraphQL::CoercionError, "#{value.inspect} is not a valid UUID"
            end
          end

          def validate_uuid(value)
            !!value.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
          end
        end
      end
    end
  end
end
