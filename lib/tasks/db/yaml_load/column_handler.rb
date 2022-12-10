# frozen_string_literal: true

module Tasks
  module Db
    module YamlLoad
      class ColumnHandler < Psych::Handler
        attr_reader :columns, :table_name

        def initialize
          super
          @col_reading = false
          @first = true
        end

        def scalar(value, _anchor, _tag, _plain, _quoted, _style)
          if @first
            @table_name = value
            @first = false
          elsif @col_reading
            @columns << value
          elsif value == "columns"
            @col_reading = true
            @columns = []
          end
        end

        def end_sequence
          @col_reading = false
        end
      end
    end
  end
end
