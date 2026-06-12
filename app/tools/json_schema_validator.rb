class JsonSchemaValidator
  VALID_TYPES = %w[object string number integer boolean array].freeze

  class Result
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def valid?
      errors.empty?
    end
  end

  def self.validate(schema, value)
    new.validate(schema, value)
  end

  def self.schema_errors(schema)
    new.schema_errors(schema)
  end

  def validate(schema, value)
    schema = normalize_hash(schema)
    return Result.new([]) if schema.empty?

    Result.new(validate_value(schema, value, "$"))
  end

  def schema_errors(schema)
    schema = normalize_hash(schema)
    return [] if schema.empty?

    validate_schema(schema, "$")
  end

  private

  def normalize_hash(value)
    return {} if value.nil?
    return value.to_h if value.respond_to?(:to_h)

    value
  end

  def validate_schema(schema, path)
    return [ "#{path} must be an object" ] unless schema.is_a?(Hash)

    errors = []
    type = schema["type"] || schema[:type]
    errors << "#{path}.type must be one of #{VALID_TYPES.join(', ')}" if type && !VALID_TYPES.include?(type)

    required = schema["required"] || schema[:required]
    if required && (!required.is_a?(Array) || required.any? { |key| !key.is_a?(String) })
      errors << "#{path}.required must be an array of strings"
    end

    properties = schema["properties"] || schema[:properties]
    if properties
      if properties.is_a?(Hash)
        properties.each do |name, child_schema|
          errors.concat(validate_schema(child_schema, "#{path}.properties.#{name}"))
        end
      else
        errors << "#{path}.properties must be an object"
      end
    end

    items = schema["items"] || schema[:items]
    errors.concat(validate_schema(items, "#{path}.items")) if items

    errors
  end

  def validate_value(schema, value, path)
    type = schema["type"] || schema[:type]
    return [] unless type

    case type
    when "object"
      validate_object(schema, value, path)
    when "array"
      validate_array(schema, value, path)
    when "string"
      value.is_a?(String) ? [] : [ "#{path} must be a string" ]
    when "integer"
      value.is_a?(Integer) && !value.is_a?(TrueClass) && !value.is_a?(FalseClass) ? [] : [ "#{path} must be an integer" ]
    when "number"
      value.is_a?(Numeric) && !value.is_a?(TrueClass) && !value.is_a?(FalseClass) ? [] : [ "#{path} must be a number" ]
    when "boolean"
      [ true, false ].include?(value) ? [] : [ "#{path} must be a boolean" ]
    else
      [ "#{path}.type is unsupported" ]
    end
  end

  def validate_object(schema, value, path)
    return [ "#{path} must be an object" ] unless value.is_a?(Hash)

    errors = []
    string_value = value.transform_keys(&:to_s)
    required = Array(schema["required"] || schema[:required])
    required.each do |key|
      errors << "#{path}.#{key} is required" unless string_value.key?(key)
    end

    properties = schema["properties"] || schema[:properties] || {}
    properties.each do |key, child_schema|
      next unless string_value.key?(key.to_s)

      errors.concat(validate_value(child_schema, string_value[key.to_s], "#{path}.#{key}"))
    end

    errors
  end

  def validate_array(schema, value, path)
    return [ "#{path} must be an array" ] unless value.is_a?(Array)

    items = schema["items"] || schema[:items]
    return [] unless items

    value.flat_map.with_index { |item, index| validate_value(items, item, "#{path}[#{index}]") }
  end
end
