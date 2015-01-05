
BUSTED = -99999

stake = 1500
laststake = 1500
openbet = 10
maxbet = 100
currentbet = openbet
cardcounting = false
progressive = false

nhands = 100000

class Globals {
  def count = 0
  def cardval = [:]
  def aceval = 999
  def ndecks = 8
  Globals() {
this.cardval = [
  'A' : aceval,
  'K' : 10,
  'Q' : 10,
  'J' : 10,
  '10' : 10,
  '9' : 9,
  '8' : 8,
  '7' : 7,
  '6' : 6,
  '5' : 5,
  '4' : 4,
  '3' : 3,
  '2' : 2
]
  }

  def gc() {
    this.cardval
  }
}

glob = new Globals()
println glob.cardval



// just to make the table easier to type:

t = true
f = false

// dealer's upcard:
//                     2    3    4    5    6    7    8    9    10   A
splitmatrix = ['A' :  [t,   t,   t,   t,   t,   t,   t,   t,   t,   t],
	       '10' : [f,   f,   f,   f,   f,   f,   f,   f,   f,   f],
	       '9'  : [t,   t,   t,   t,   t,   f,   t,   t,   f,   f],
	       '8'  : [t,   t,   t,   t,   t,   t,   t,   t,   t,   t],
	       '7'  : [t,   t,   t,   t,   t,   t,   f,   f,   f,   f],
	       '6'  : [t,   t,   t,   t,   t,   f,   f,   f,   f,   f],
	       '5'  : [f,   f,   f,   f,   f,   f,   f,   f,   f,   f],
	       '4'  : [f,   f,   f,   f,   t,   t,   f,   f,   f,   f],
	       '3'  : [t,   t,   t,   t,   t,   t,   f,   f,   f,   f],
	       '2'  : [t,   t,   t,   t,   t,   t,   f,   f,   f,   f]
	       ]
	       
println splitmatrix

allstand = '- - - - - - - - - -'.split(' ')
hit7onup = '- - - - - h h h h h'.split(' ')
justhit = 'h h h h h h h h h h'.split(' ')

actmatrix = ['soft21' : allstand,
	     'soft20' : allstand,
	     'soft19' : allstand,
	     'soft18' : '- d d d d - - h h h'.split(' '),
	     'soft17' : 'h d d d d h h h h h'.split(' '),
	     'soft16' : 'h h d d d h h h h h'.split(' '),
	     'soft15' : 'h h d d d h h h h h'.split(' '),
	     'soft14' : 'h h h d d h h h h h'.split(' '),
	     'soft13' : 'h h h h d h h h h h'.split(' '),
	     21 : allstand,
	     20 : allstand,
	     19 : allstand,
	     18 : allstand,
	     17 : allstand,
	     16 : hit7onup,
	     15 : hit7onup,
	     14 : hit7onup,
	     13 : hit7onup,
	     12 : 'h h - - - h h h h h'.split(' '),
	     11 : 'd d d d d d d d d h'.split(' '),
	     10 : 'd d d d d d d d h h'.split(' '),
	     9  : 'd d d d d d d h h h'.split(' '),
	     8  : justhit,
	     7  : justhit,
	     6  : justhit,
	     5  : justhit,
	     4  : justhit
	     ]

println actmatrix

cardarray = ['A' : 9,
             'K' : 8,
             'Q' : 8,
             'J' : 8,
             '10' : 8,
	     ]

println cardarray

valuesquash = ['K' : '10',
	       'Q' : '10',
	       'J' : '10'
	       ]

countvals = ['A' : -1,
              'K' : -1,
              'Q' : -1,
              'J' : -1,
              '10' : -1,
              '9' : 0,
              '8' : 0,
              '7' : 0,
              '6' : 1,
              '5' : 1,
              '4' : 1,
              '3' : 1,
              '2' : 1
]

def bumpcount(card) {
  count += countvals[card.getspot()]
}

def upcardarraydoodad(upcard) {
  card = upcard.getspot()
  if (cardarray[card]) {
      return cardarray[card]
    }
  return card.toInteger() - 2
}



class Card {
  def suit
  def spot
  Card(suit,spot) {
    this.suit = suit
    this.spot = spot
  }
  def getspot() {
    this.spot
  }
}

class Deck {
  def deck = []
  def curdeck = []
  def multideck = []
  def deckmarker = []
  def glob
  def nd
  Deck(glob) {
    this.glob = glob
    this.deck = []
    this.curdeck = []
    for (suit in ['spades', 'hearts', 'diamonds', 'clubs']) {
      glob.cardval.each {
        deck.push(new Card(suit,it))
      }
     
    }
    for (n in 0 .. 51) {
      deckmarker[n] = n
    }
    this.multideck = setup()
  }
    def md() {
      this.multideck
    }
    def shuffle() {
      Collections.shuffle(deckmarker)
      println "deckmarker after shuffle:"
      println deckmarker
      curdeck = []
      for (k in 0 .. 51) {
	/*	println "k= ${k}"
	println "dk = ${deckmarker[k]}"
	println "deckof: ${deck[deckmarker[k]]}"
	*/
	  curdeck.push(deck[deckmarker[k]])
	}
      curdeck
    }
    def setup() {
      multideck = []
      for (i in 1 .. glob.ndecks) {
	  nd = shuffle()
	  multideck += nd
	}
      multideck
    }

    def cardno() {
      return this.cardno
    }

    def getcard() {
      if (cardno()  > 0.75 * multideck.length) {
	multideck = setup()
      }
      card = multideck[cardno += 1]
      bumpcount(card)
      return card
    }
}

class Hand {
  def bet
  def who
  def busted = false
  def blackjack = false
  def dealer
  def hiddencard
  def upcard
  def cards = []
  def Hand(globs,who,dealer,card1 = null, card2 = null) {
    this.globs = globs
    this.bet = globs.currentbet
    this.who = who
    this.dealer = dealer
    if (dealer) {
      hiddencard = card1
      upcard = card2
    }
    else {
      this.card1 = card1
      this.card2 = card2
      this.cards = [card1,card2]
    }
  }
  def resetvalue() {
    cards = []
    busted = false
    blackjack = false
    bet = this.globs.currentbet
  }

  def setcard(k,val) {
    if (dealer) {
      if (k == 1) {
        upcard = val
      }
      else {
        hiddencard = val
      }
    }
    else
      if ( k == 0) {
          card1 = val
      }
      else
	{
          card2 = val
        }

    cards[k] = val
  }
}

  deck = new Deck(glob)
  multideck = deck.md()

  multideck.each {
    println "${it.suit} ${it.spot}"
  }


