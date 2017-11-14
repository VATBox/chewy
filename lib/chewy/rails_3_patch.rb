if defined?(Rails)  && Rails::VERSION::MAJOR > 3
  raise "Use standard chewy version #{__FILE__}"
end

module PluckAllExtension
  module Relation
    def pluck_all(*args)
      args.map! do |column_name|
        if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
          "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
        else
          column_name.to_s
        end
      end

      relation = clone
      relation.select_values = args
      klass.connection.select_all(relation.arel).map! do |attributes|
        initialized_attributes = klass.initialize_attributes(attributes)
        attributes.each do |key, attribute|
          attributes[key] = klass.type_cast_attribute(key, initialized_attributes)
        end
      end
    end
  end

  # ARClass.puck_all
  module Base
    extend ActiveSupport::Concern

    included do
      def self.pluck_all(*args)
        scoped.pluck_all(*args)
      end
    end
  end
end

ActiveRecord::Relation.send :include, PluckAllExtension::Relation
ActiveRecord::Base.send     :include, PluckAllExtension::Base