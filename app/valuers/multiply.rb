# frozen_string_literal: true

class Multiply
  def initialize(leftfunc, rightfunc, offset)
    @leftfunc = leftfunc
    @rightfunc = rightfunc
    @offset = offset
  end

  def func(exp)
    @leftfunc.func(exp) * @rightfunc.func(exp) - @offset
  end

  def funcdash(exp)
    @leftfunc.func(exp) * @rightfunc.funcdash(exp) + @rightfunc.func(exp) * @leftfunc.funcdash(exp)
  end
end
