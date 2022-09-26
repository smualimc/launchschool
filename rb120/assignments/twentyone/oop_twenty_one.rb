module Displayable
  def prompt(message)
    puts ">> #{message}"
    skip
  end

  def clear_screen
    system 'clear'
    skip
  end

  def skip
    puts ""
  end
end

class Gamblers
  include Displayable
  attr_accessor :hand, :bust

  def initialize
    @hand = []
    @bust = false
  end
end

class Player < Gamblers
  attr_accessor :name

  def initialize
    super
    enter_name
  end

  def enter_name
    prompt("please enter your name")
    input = ''
    loop do
      input = gets.chomp.strip
      break unless input.empty?
      prompt("You can't leave your name in blank")
    end
    @name = input
  end
end

class Dealer < Gamblers
  attr_accessor :badge

  def initialize
    super
    create_badge
  end

  def create_badge
    @badge = "Dealer-ID: #{(101..299).to_a.sample}"
  end
end

class Cards
  attr_accessor :deck

  REVERSE = "\uF0A0"
  SPADE = "\u2660"
  CLUB = "\u2663"
  HEART = "\u2665"
  DIAMOND = "\u2666"
  SUITES = %W(#{SPADE} #{CLUB} #{HEART} #{DIAMOND})
  VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  WEIGHTS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 1]

  def initialize
    create_a_new_one
  end

  def create_a_new_one
    @deck = VALUES.product(SUITES).map(&:join)
  end
end

class Game
  include Displayable

  attr_accessor :cards, :dealer, :player, :first_game

  def play
    welcome_message
    new_game
    playing
    end_message
  end

  def welcome_message
    clear_screen
    prompt("Welcome to the Twenty-One game")
  end

  def new_game
    @dealer = Dealer.new
    @player = Player.new
    @first_game = true
    reset_scores
  end

  def show_running_score
    prompt("Running scores: #{player.name}: #{@player_points} - Dealer #{@dealer_points}")
  end

  def reset_scores
    @player_points = 0
    @dealer_points = 0
  end

  def playing
    loop do
      new_deck
      initial_deal
      player_turn
      dealer_turn
      show_winner
      show_running_score
      break unless play_again?
    end
  end

  def new_deck
    @cards = Cards.new
  end

  def initial_deal
    player_deal
    dealer_deal
  end

  def player_deal
    2.times { player.hand.push(cards.deck.delete(cards.deck.sample)) }
  end

  def dealer_deal
    2.times { dealer.hand.push(cards.deck.delete(cards.deck.sample)) }
  end

  def player_turn
    loop do
      show_cards
      prompt("Would you like (a)nother card or (s)tay?")
      break if give_option == 'stay'
      new_deal(player)
      result = compute_hand(player)
      player.bust = true if result > 21
      break if player.bust
    end
  end

  def show_cards
    show_player_hand
    show_hidden_hand
  end

  def show_player_hand
    clear_screen
    # rubocop:disable Layout/LineLength
    prompt("We are glad that you want keep playing #{player.name}") unless first_game
    # rubocop:enable Layout/LineLength
    prompt("Cards on the table")
    prompt("#{player.name} cards: #{player.hand.join(' | ')} = #{compute_hand(player)}")
  end

  def show_hidden_hand
    prompt("#{dealer.badge} cards: #{dealer.hand[0]} | #{Cards::REVERSE}}")
  end

  def give_option
    option = ''
    loop do
      option = gets.chomp.downcase
      break if ['a', 's'].include? option
      prompt("Please enter a correct option")
    end
    option == 'a' ? 'another' : 'stay'
  end

  # rubocop:disable Metrics/AbcSize
  def new_deal(gambler)
    if gambler.instance_of?(Player)
      player.hand << (cards.deck.delete(cards.deck.sample))
    else
      dealer.hand << (cards.deck.delete(cards.deck.sample))
    end
  end

  def compute_hand(gambler)
    array = gambler.instance_of?(Player) ? player.hand : dealer.hand
    values_array = array.map(&:chop)
    keys_array = values_array.map { |value| Cards::VALUES.index(value) }
    weights_array = keys_array.map { |key| Cards::WEIGHTS[key] }
    weight = weights_array.sum
    if (weights_array.include?(1)) && ((weight + 10) <= 21)
      weight += 10
    end
    weight
  end

  def dealer_turn
    loop do
      show_hidden_cards
      break if unnecessary_deal?
      new_deal(dealer) if meets_rules?
      dealer.bust = true if compute_hand(dealer) > 21
      break if dealer.bust || compute_hand(dealer) > 16
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show_hidden_cards
    show_player_hand
    show_dealer_hand
  end

  def unnecessary_deal?
    player.bust || (compute_hand(dealer) > compute_hand(player))
  end

  def meets_rules?
    compute_hand(dealer) < 17 && (compute_hand(player) >= compute_hand(dealer))
  end

  def show_dealer_hand
    prompt("#{dealer.badge} cards: #{dealer.hand.join(' | ')} = #{compute_hand(dealer)}")
  end

  def show_winner
    if player.bust || dealer.bust
      winner_by_busting
    else
      winner_by_weight
    end
  end

  def player_scores
    @player_points += 1
  end

  def dealer_scores
    @dealer_points +=1
  end

  def increment_score(gambler)
    gambler.instance_of?(Player)? player_scores : dealer_scores
  end

  def winner_by_busting
    show_hidden_cards
    if player.bust
      prompt("#{player.name} busts, home won this time!")
      increment_score(dealer)
    else
      prompt("Dealer busts, #{player.name} won!")
      increment_score(player)
    end
  end

  def winner_by_weight
    show_hidden_cards
    if dealer_won?
      show_dealer_won
      increment_score(dealer)
    elsif dealer_lost?
      show_player_won
      increment_score(player)
    else
      show_tie
    end
  end

  def dealer_won?
    compute_hand(dealer) > compute_hand(player)
  end

  # rubocop: disable Layout/LineLength
  def show_dealer_won
    prompt("#{dealer.badge} won, he got #{compute_hand(dealer)} points and you got just  #{compute_hand(player)}")
  end

  def dealer_lost?
    compute_hand(dealer) < compute_hand(player)
  end

  def show_player_won
    prompt("#{player.name} won, you got #{compute_hand(player)} points and he got just  #{compute_hand(dealer)}")
  end

  def show_tie
    prompt("It was a tie, both of you got #{compute_hand(dealer)}, at least kept your money!")
  end
  # rubocop:enable Layout/LineLength

  def play_again?
    prompt("Would you like to play again? (y)es + Enter or just Enter to quit")
    option = gets.chomp.downcase
    if option == 'y'
      reset_hands
      return true
    end
    false
  end
end

# rubocop:disable Lint/UselessAssignment
def reset_hands
  player.hand = []
  dealer.hand = []
  player.bust = false
  dealer.bust = false
  @first_game = false
end
# rubocop:enable Lint/UselessAssignment

def end_message
  clear_screen
  prompt('Thank you for playing Twenty-one, good bye!')
end

Game.new.play
