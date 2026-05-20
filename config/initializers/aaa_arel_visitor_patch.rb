require 'arel/visitors/to_sql'

module Arel
  module Visitors
    class ToSql
      private

      def visit_Integer(o, a = nil)
        o.to_s
      end
    end
  end
end
