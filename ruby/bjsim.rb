#!/usr/bin/ruby

$aceval = 999
$BUSTED = -99_999

$stake = 1500
$laststake = 1500
$openbet = 10
$maxbet = 100
$currentbet = $openbet
$cardcounting = true
$progressive = false
$count = 0

$nhands = 100_000

$cardval = { 'A' => $aceval,
             'K' => 10,
             'Q' => 10,
             'J' => 10,
             '10' => 10,
             '9' => 9,
             '8' => 8,
             '7' => 7,
             '6' => 6,
             '5' => 5,
             '4' => 4,
             '3' => 3,
             '2' => 2 }

# determine action based on player's hand and dealer's upcard

# $actmatrix =
#
#                        2     3     4      5    6     7     8     9    10     A
$splitmatrix = { 'A' => [true, true, true, true, true, true, true, true, true, true],
                 '10' => [false, false, false, false, false, false, false, false, false, false],
                 '9' => [true, true, true, true, true, false, true, true, false, false],
                 '8' => [true, true, true, true, true, true, true, true, true, true],
                 '7' => [true, true, true, true, true, true, false, false, false, false],
                 '6' => [true, true, true, true, true, false, false, false, false, false],
                 '5' => [false, false, false, false, false, false, false, false, false, false],
                 '4' => [false, false, false, true, true, false, false, false, false, false],
                 '3' => [true, true, true, true, true, true, false, false, false, false],
                 '2' => [true, true, true, true, true, true, false, false, false, false] }

$actmatrix = {
  'soft21' => %w[- - - - - - - - - -],
  'soft20' => %w[- - - - - - - - - -],
  'soft19' => %w[- - - - - - - - - -],
  'soft18' => %w[- d d d d - - h h h],
  'soft17' => %w[h d d d d h h h h h],
  'soft16' => %w[h h d d d h h h h h],
  'soft15' => %w[h h d d d h h h h h],
  'soft14' => %w[h h h d d h h h h h],
  'soft13' => %w[h h h h d h h h h h],
  21 => %w[- - - - - - - - - -],
  20 => %w[- - - - - - - - - -],
  19 => %w[- - - - - - - - - -],
  18 => %w[- - - - - - - - - -],
  17 => %w[- - - - - - - - - -],
  16 => %w[- - - - - h h h h h],
  15 => %w[- - - - - h h h h h],
  14 => %w[- - - - - h h h h h],
  13 => %w[- - - - - h h h h h],
  12 => %w[h h - - - h h h h h],
  11 => %w[d d d d d d d d d h],
  10 => %w[d d d d d d d d h h],
  9 => %w[d d d d d d d h h h],
  8 => %w[h h h h h h h h h h],
  7 => %w[h h h h h h h h h h],
  6 => %w[h h h h h h h h h h],
  5 => %w[h h h h h h h h h h],
  4 => %w[h h h h h h h h h h]
}

$cardarray = { 'A' => 9,
               'K' => 8,
               'Q' => 8,
               'J' => 8,
               '10' => 8 }

$valuesquash = { 'K' => '10',
                 'Q' => '10',
                 'J' => '10' }

$countvals = { 'A' => -1,
               'K' => -1,
               'Q' => -1,
               'J' => -1,
               '10' => -1,
               '9' => 0,
               '8' => 0,
               '7' => 0,
               '6' => 1,
               '5' => 1,
               '4' => 1,
               '3' => 1,
               '2' => 1 }

def bumpcount(card)
  #  printf("count=%d spot = %s\n",$count,card.getspot())
  $count += $countvals[card.getspot]
  #  printf("count after: %d\n",$count)
end

def upcardarraydoodad(upcard)
  # upcard = [suit,card]
  card = upcard.getspot
  #  puts 'card =', card
  if $cardarray.has_key?(card)
    #    puts 'has key!'
    return $cardarray[card]
  end

  card.to_i - 2
  #  puts 'returning n, n = ',n
end

$deckmarker = (0..51).to_a # make range a list
$ndecks = 8

class Card
  def initialize(suit, spot)
    @suit = suit
    @spot = spot
  end

  def getspot
    @spot
  end
end

class Deck
  def initialize
    @deck = []
    @curdeck = []
    %w[spades hearts diamonds clubs].each do |suit|
      $cardval.keys.each do |card|
        c = Card.new(suit, card)
        @deck.push(c)
      end
    end
    @multideck = setup
  end

  def md
    @multideck
  end

  def shuffle
    newdeck = $deckmarker.shuffle!
    @curdeck = []
    (0..51).each do |k|
      @curdeck.push(@deck[newdeck[k]])
    end
    @curdeck
  end

  def setup
    multideck = []
    (1..$ndecks).each do |_i|
      nd = shuffle
      multideck += nd
    end
    @cardno = 0
    multideck
  end

  attr_reader :cardno

  def getcard
    @multideck = setup if @cardno > 0.75 * @multideck.length
    card = @multideck[@cardno += 1]
    bumpcount(card)
    card
  end
end

# puts deck

$deck = Deck.new

$multideck = $deck.md

class Hand
  def initialize(who, dealer = false, card1 = nil, card2 = nil)
    @who = who
    @bet = $currentbet
    @busted = false
    @blackjack = false
    @dealer = dealer
    if dealer
      @dealer = true
      @hiddencard = card1
      @upcard = card2
      @cards = [card1, card2]
    else
      @dealer = false
      @card1 = card1
      @card2 = card2
      @cards = [card1, card2]
    end
  end

  def resetvalue
    @cards = []
    @busted = false
    @blackjack = false
    @bet = $currentbet
  end

  def setbusted
    @busted = true
  end

  def blackjack
    @blackjack = true
  end

  def isblackjack
    @blackjack
  end

  def isbusted
    @busted
  end

  def getupcard
    @upcard
  end

  def setbet(bet)
    @bet = bet
  end

  def getbet
    @bet
  end

  def getcard(k)
    @cards[k]
  end

  def setcard(k, val)
    if @dealer
      if k == 1
        @upcard = val
      else
        @hiddencard = val
      end
    elsif k == 0
      @card1 = val
    else
      @card2 = val
    end
    @cards[k] = val
    @cards[k]
  end

  def split
    newcard1 = $deck.getcard
    newcard2 = $deck.getcard
    setcard(1, newcard1)
    printf("hand1 after split: %s %s\n", @cards[0].getspot, newcard1.getspot)
    newhand = Hand.new('split hand', false, getcard(0), newcard2)
    printf("hand2 after split: %s %s\n", newhand.getcard(0).getspot, newhand.getcard(1).getspot)
    newhand
  end

  def setvalue(v)
    @valuesetonce = true
    @value = [false, v]
  end

  def value
    valu = 0
    soft = false
    @cards.each do |c|
      spot = c.getspot
      if spot == 'A'
        soft = true
        valu += 1
      else
        #        printf("spot: %s\n",c.getspot())
        valu += $cardval[c.getspot]
      end
    end
    if soft
      if valu <= 11
        valu += 10
      else
        soft = false
      end
    end

    if (valu == 21) && (@cards.length == 2)
      printf('BLACKJACK FOUND!')
      blackjack
      soft = false
    end
    @value = [soft, valu]
  end

  def combinedvalue
    (soft, v) = value
    if soft
      retval = format('soft%d', v)
      @soft = true
    else
      @soft = false
      retval = v
    end
    #    puts "retval =",retval
    [retval, v]
  end

  def hit
    newcard = $deck.getcard
    @cards.push(newcard)
    printf("HIT: %s\n", newcard.getspot)
  end
end

class Deal
  def initialize
    $deck.setup if $deck.cardno > 0.75 * $multideck.length
    @dealerhand = Hand.new('dealer', true)
    @playerhand = Hand.new('player')
    @allplayers = [@dealerhand, @playerhand]
    @players = [@playerhand] # splits will be added
  end

  def getdealer
    @dealerhand
  end

  attr_reader :players

  def deal
    @players = [@playerhand]
    @playerhand.resetvalue
    @dealerhand.resetvalue
    (0..1).each do |k|
      @allplayers.each do |hand|
        hand.setcard(k, $deck.getcard)
      end
    end
  end

  def print
    printf("dealer: (%p,%p)\nplayer: (%p,%p)\n", @dealerhand.getcard(0), @dealerhand.getcard(1), @playerhand.getcard(0),
           @playerhand.getcard(1))
    (dsoft, dealervalue) = @dealerhand.value
    (psoft, playervalue) = @playerhand.value
    dsoft = if dsoft
              'soft'
            else
              ''
            end
    psoft = if psoft
              'soft'
            else
              ''
            end
    printf("dealer's upcard: %s\n", @dealerhand.getupcard.getspot)
    printf("dealer value: %s %s\n", dsoft, dealervalue)
    printf("player value: %s %s\n", psoft, playervalue)
    printf("player bets: %d\n", @playerhand.getbet)
  end

  def shouldwesplit(playerhand)
    upper = @dealerhand.getupcard
    upval = upcardarraydoodad(upper)
    # first, can we split?
    if (card = playerhand.getcard(0).getspot) != playerhand.getcard(1).getspot
      return false
    end

    printf("checking for split: player card: %p dealer upcard: %p\n", playerhand.getcard(0), @dealerhand.getupcard)
    val = if $valuesquash.has_key?(card)
            $valuesquash[card]
          else
            card
          end

    #   puts 'val =',val
    #   puts 'playercard = ', card

    #   puts 'upper = ', upper
    $splitmatrix[val][upval]
  end

  def doubledown(hand, _v)
    hand.setbet(hand.getbet * 2)
    newcard = hand.hit
    hand.value
  end

  def dealeraction
    puts 'DEALER ACTION ...'
    (soft, v) = @dealerhand.value
    return 21 if @dealerhand.isblackjack

    while true
      if v > 21
        puts 'dealer BUSTED'
        @dealerhand.setbusted
        return $BUSTED
      elsif ((v == 17) && soft) || (v < 17)
        @dealerhand.hit
        (soft, v) = @dealerhand.value
      else
        printf("dealer STANDS on %d\n", v)
        return @dealerhand.value
      end
    end
  end

  def playeraction(hand)
    puts 'PLAYER ACTION .....'
    if shouldwesplit(hand)
      puts 'SPLIT!!!!!!'
      newhand = hand.split
      @players.push(newhand)
      playeraction(hand) # changed after split
      playeraction(newhand)
      return
    end
    upper = @dealerhand.getupcard
    #    puts 'upper = ',upper
    upval = upcardarraydoodad(upper)
    (playervalue, v) = hand.combinedvalue
    printf("playervalue: %s\n", playervalue.to_s)
    return hand.value if v == 'BLACKJACK'

    first = true
    while true
      printf("pv: %s upval: %d\n", playervalue.to_s, upval)
      action = $actmatrix[playervalue][upval]
      if action == '-'
        printf("player STANDs on %s ....\n", playervalue.to_s)
        return hand.value
      elsif first && (action == 'd')
        puts('DOUBLE DOWN!')
        return doubledown(hand, v)
      else
        first = false
        hand.hit
        (soft, v) = hand.value
        if v > 21
          hand.setbusted
          puts('player BUSTED')
          return $BUSTED
        end
        if v >= 17
          puts 'STAND ...'
          return hand.value
        else
          (playervalue, v) = hand.combinedvalue
          printf("playervalue(bottom): %s\n", playervalue.to_s)
        end
      end
    end
  end
end

def compare(dealerobj, playerobj)
  dealer = dealerobj.combinedvalue[1]
  player = playerobj.combinedvalue[1]
  if playerobj.isbusted
    puts('player BUSTED, no comparison')
    $stake -= playerobj.getbet
    return
  end
  if dealerobj.isbusted
    puts('dealer BUSTED, player wins!')
    $stake += playerobj.getbet
    return
  end
  if playerobj.isblackjack
    if dealerobj.isblackjack
      puts 'PUSH -- 2 blackjacks'
      return
    else
      puts 'player BLACKJACK'
      $stake += 1.5 * playerobj.getbet
      return
    end
  end
  if dealerobj.isblackjack
    puts 'dealer BLACKJACK'
    $stake -= playerobj.getbet
    return
  end
  ps = player.to_s
  ds = dealer.to_s
  printf("ps: %s ds: %s\n", ps, ds)
  ps.sub('soft', '')
  ds.sub('soft', '')
  pi = ps.to_i
  di = ds.to_i
  printf("comparing -- player: %d dealer %d\n", pi, di)
  if pi == di
    puts 'PUSH'
    nil
  elsif pi > di
    puts 'PLAYER WINS'
    $stake += playerobj.getbet
  else
    puts 'DEALER WINS'
    $stake -= playerobj.getbet
  end
end

def adjusted_count
  maxcards = $ndecks * 52
  unseen = maxcards - $deck.cardno
  decks_unseen = unseen.to_f / 52.0
  $count / decks_unseen
end

def resetbet
  if $progressive
    return if $laststake == $stake

    if $laststake > $stake
      $currentbet = $currentbet / 2
    else
      $currentbet += (0.5 * ($stake - $laststake))
    end
    $currentbet = $maxbet if $currentbet > $maxbet
    $currentbet = $openbet if $currentbet < $openbet
  else # counting
    a = adjusted_count
    $currentbet = if a < 1
                    $openbet
                  elsif (a > 1) && (a < 2)
                    $openbet * 2
                  elsif (a > 2) && (a < 3)
                    $openbet * 3
                  else
                    $openbet * 4
                  end
  end
end

d = Deal.new
(1..$nhands).each do |looper|
  $laststake = $stake
  printf("nloop: %d stake: %d currentbet: %d count: %d adjcount: %d\n", looper, $stake, $currentbet, $count,
         adjusted_count)
  if $stake <= 0
    puts 'WENT BROKE!'
    break
  end
  d.deal
  d.getdealer.value
  d.players[0].value

  d.print
  if d.getdealer.isblackjack
    if !d.players[0].isblackjack
      printf("dealer BLACKJACK -- player loses\n")
      $stake -= d.players[0].getbet
      resetbet
      next
    else
      printf("both BLACKJACK -- PUSH\n")
      next
    end
  end

  d.playeraction(d.players[0])

  if (dealer = d.dealeraction) == $BUSTED
    puts 'dealer BUSTED'
  end
  printf("after dealer action, value: %p\n", d.getdealer.value)
  d.players.each do |player|
    compare(d.getdealer, player)
  end
  resetbet
end
printf("stake: %d\n", $stake)
