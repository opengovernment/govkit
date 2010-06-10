module GovKit
  class GovKitError < StandardError
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message  = message
    end

    def to_s
      "Failed with #{response.code} #{response.message if response.respond_to?(:message)}"
    end
  end

  class NotAuthorized < GovKitError;
  end

  class InvalidRequest < GovKitError;
  end

  class ResourceNotFound < GovKitError;
  end

  class Resource
    include HTTParty
    format :json

    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = {}
      unload(attributes)
    end

    class << self
      def instantiate_record(record)
        raise GovKit::ResourceNotFound, "Resource not found" unless record
        new(record)
      end

      def instantiate_collection(collection)
        collection.collect! { |record| instantiate_record(record) }
      end

      def parse(json)
        instantiate_record(json)
      end
    end

    def unload(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.each do |key, value|
        @attributes[key.to_s] =
          case value
            when Array
              resource = resource_for_collection(key)
              value.map do |attrs|
                if attrs.is_a?(String) || attrs.is_a?(Numeric)
                  attrs.duplicable? ? attrs.dup : attrs
                else
                  resource.new(attrs)
                end
              end
            when Hash
              resource = find_or_create_resource_for(key)
              resource.new(value)
            else
              value.dup rescue value
          end
      end
      self
    end

    private
    def resource_for_collection(name)
      find_or_create_resource_for(name.to_s.singularize)
    end

    def find_resource_in_modules(resource_name, module_names)
      receiver = Object
      namespaces = module_names[0, module_names.size-1].map do |module_name|
        receiver = receiver.const_get(module_name)
      end
      if namespace = namespaces.reverse.detect { |ns| ns.const_defined?(resource_name) }
        return namespace.const_get(resource_name)
      else
        raise NameError, "Namespace for #{namespace} not found"
      end
    end

    def find_or_create_resource_for(name)
      resource_name = name.to_s.camelize
      ancestors = self.class.name.split("::")
      if ancestors.size > 1
        find_resource_in_modules(resource_name, ancestors)
      else
        self.class.const_get(resource_name)
      end
    rescue NameError
      if self.class.const_defined?(resource_name)
        resource = self.class.const_get(resource_name)
      else
        resource = self.class.const_set(resource_name, Class.new(GovKit::Resource))
      end
      resource
    end

    def method_missing(method_symbol, * arguments) #:nodoc:
      method_name = method_symbol.to_s

      case method_name.last
        when "="
          attributes[method_name.first(-1)] = arguments.first
        when "?"
          attributes[method_name.first(-1)]
        when "]"
          attributes[arguments.first.to_s]
        else
          attributes.has_key?(method_name) ? attributes[method_name] : super
      end
    end
  end
end
