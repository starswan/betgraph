# frozen_string_literal: true

module Tasks
  module Db
    module YamlLoad
      class RecordsHandler < Psych::Handler
        # rubocop:disable Rails/SaveBang
        def initialize(enumerator)
          super()
          @enumerator = enumerator
          @rec = false
          @data_rec = false
          @visitor = Psych::Visitors::ToRuby.create
        end
        # rubocop:enable Rails/SaveBang

        def scalar(value, anchor, tag, plain, quoted, style)
          if @data_rec
            scalar = Psych::Nodes::Scalar.new(value, anchor, tag, plain, quoted, style)
            @data << @visitor.accept(scalar)
          elsif value == "records"
            @rec = true
          end
        end

        def start_sequence(_anchor, _tag, _implicit, _style)
          if @rec
            @data = []
            @data_rec = true
          end
        end

        def end_sequence
          if @data_rec
            @data_rec = false
            @enumerator << @data
          end
        end
      end
    end
  end
end
