# frozen_string_literal: true

module Tasks
  module Db
    module YamlLoad
      class Dumper < YamlDb::Dump
        class << self
          def tables
            # team_totals is big and cen be generated from result data (and may not be required anyway)
            # logins doesn't seem to port well to postgres via insert statements ?
            all = super - %w[team_totals results logins]
            # all = super - %w[logins]
            big = %w[market_prices]
            (all - big) + big
          end

          def each_table_page(table, records_per_page = 1000)
            if table == "ar_internal_metadata"
              super
            else
              total_count = table_record_count(table)
              pages = (total_count.to_f / records_per_page).ceil - 1
              keys = sort_keys(table)
              boolean_columns = YamlDb::SerializationHelper::Utils.boolean_columns(table)
              last_id = 0

              (0..pages).to_a.each do |_page|
                arel_table = Arel::Table.new(table)
                query = arel_table.order(*keys).where(arel_table[:id].gt(last_id)).take(records_per_page).project(Arel.sql("*"))
                records = ActiveRecord::Base.connection.select_all(query.to_sql)
                converted = records.map { |r| convert_booleans(r, boolean_columns) }
                yield converted
                last_id = records.last.fetch("id") if records.any?
              end
            end
          end

          def convert_booleans(record, columns)
            converting = columns.reject { |c| YamlDb::SerializationHelper::Utils.is_boolean(record[c]) }
            if converting.any?
              record.map { |k, v|
                if k.in? converting
                  [k, YamlDb::SerializationHelper::Utils.convert_boolean(v)]
                else
                  [k, v]
                end
              }.to_h
            else
              record
            end
          end
        end
      end
    end
  end
end
