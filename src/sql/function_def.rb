require 'sql/type'
require 'sql/type_predicates'

module Sql
  class FunctionDef
    include TypePredicates

    def self.truncate(name, slab)
      slab = slab.to_i
      f = self.new(name, 'I')
      f.summarisable = true
      f.expr = "DIV(%s, #{slab}) * #{slab}"
      f
    end

    attr_reader :name
    attr_accessor :type, :summarisable, :expr, :display_format

    def initialize(name, cfg)
      @name = name
      @cfg = cfg
      if @cfg.is_a?(String)
        @cfg = { 'type' => @cfg }
      end
      @type = Type.type(@cfg['type'])
      @summarisable = @cfg['summarisable']
      @display_format = @cfg['display-format']
      @preserve_unit = @cfg['preserve-unit']
      @unit = @cfg['unit']
      @expr = @cfg['expr']
      @return_type = Type.type(@cfg['return'] || '*')
    end

    def return_type(field)
      find_return_type(field).with_unit(unit(field))
    end

    def preserve_unit?
      @preserve_unit
    end

    def summarisable?
      @summarisable
    end

    def expr
      @expr || "#{@name}(%s)"
    end

    def === (name)
      @name == name
    end

    def to_s
      @name
    end

  private
    def find_return_type(field)
      expr = Sql::FieldExpr.expr(field)
      return @return_type unless @return_type.any?
      expr.type
    end

    def unit(field)
      expr = Sql::FieldExpr.expr(field)
      return expr.unit if preserve_unit?
      @unit
    end
  end
end