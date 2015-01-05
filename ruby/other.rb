class Bogus

def doubledown(v)
   $bet = $bet * 2
   newcard = @playerhand.hit()
   if newcard == $aceval
      v += 1
      if v < 12
       playervalue = sprintf("soft%d",v)
    else
       playervalue = v
    end
    return playervalue
end

def playeraction()
    if shouldwesplit()
      puts 'split?!'
    else
      puts 'no split!'
    end
    upper = @dealerhand.getupcard()
    upval = upcardarraydoodad(upper)
    (playervalue,v) = @playerhand.combinedvalue()

    if v == 'BLACKJACK'
      return v
    end
end

end





def playeraction()
    if shouldwesplit()
      puts 'split?!'
    else
      puts 'no split!'
    end
    upper = @dealerhand.getupcard()
    upval = upcardarraydoodad(upper)
    (playervalue,v) = @playerhand.combinedvalue()

    if v == 'BLACKJACK'
      return v
    end
    first = true
    while true
      action = $actmatrix[playervalue][upval]
      if action == '-'
        return @playerhand.value()
      elsif first and action == 'd'
        return @playerhand.doubledown(v)
      else
        first = false
        v += newcard
        if v > 21
          return $BUSTED
        end
      end
    end
end


def doubledown(v)
   $bet = $bet * 2
   newcard = @playerhand.hit()
   if newcard == $aceval
      v += 1
      if v < 12
        playervalue = sprintf("soft%d",v)
      else
        playervalue = v
      end
    end
    return playervalue
end
