# frozen_string_literal: true

#
# $Id$
#
class PriceSet
  MINIMUM_BET_AMOUNT = 1.00

  RawPrice = Struct.new :price, :amount

  attr_reader :betType

  def initialize(bet_type)
    @betType = bet_type
    @pricedata = []
  end

  def empty?
    @pricedata.empty?
  end

  def effectivePrice(target)
    bet = (target / @pricedata[0].price).round(2)
    if bet > @pricedata[0].amount && @pricedata.size > 1
      if bet > (@pricedata[0].amount + @pricedata[1].amount) && @pricedata.size > 2
        effectiveprice = (@pricedata[0].amount * @pricedata[0].price + @pricedata[1].amount * @pricedata[1].price + (bet - @pricedata[0].amount - @pricedata[1].amount) * @pricedata[2].price) / bet
      else
        effectiveprice = (@pricedata[0].amount * @pricedata[0].price + (bet - @pricedata[0].amount) * @pricedata[1].price) / bet
      end
    else
      effectiveprice = @pricedata[0].price
    end
    [effectiveprice.to_f, bet.to_f]
  end

  def probability
    @pricedata.empty? ? 1 : 1.0 / @pricedata[0].price
  end

  def price
    @pricedata.empty? ? 0 : @pricedata[0].price
  end

  def amount
    @pricedata[0].amount
  end

protected

  def addRawPrice(price, amount)
    @pricedata << RawPrice.new(price, amount)
  end
end
