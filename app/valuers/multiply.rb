#
# $Id$
#
class Multiply
  def initialize(leftfunc, rightfunc)
    @leftfunc = leftfunc
    @rightfunc = rightfunc
  end

  def func(exp)
    @leftfunc.func(exp) * @rightfunc.func(exp)
  end

  def funcdash(exp)
    @leftfunc.func(exp) * @rightfunc.funcdash(exp) + @rightfunc.func(exp) * @leftfunc.funcdash(exp)
  end
end
