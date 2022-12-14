require 'pry'

module Displayable
  def prompt(message)
    skip
    puts "> #{message}"
  end

  def clear_screen
    system 'clear'
  end

  def skip
    puts ""
  end

  def any_key_to_continue?
    prompt("Press any key to continue")
    gets.chomp.match?(/.+/)
  end
end

class Players
  include Displayable

  attr_accessor :mark, :name, :sequence

  COMPUTER_NAMES = %w(Robocop Terminator MyRobot Robottina)

  @@human_mark = ''

  def initialize
    settings
  end
end

class Human < Players
  def settings
    set_name
    set_mark
  end

  def choose_mark
    option = ''
    loop do
      option = gets.chomp.upcase
      break if %w(X O).include? option
      prompt("Sorry, wrong option, just enter X or O")
    end
    option
  end

  def set_mark
    clear_screen
    prompt("As your game's mark, would you want X or O?")
    skip
    chosen_mark = choose_mark
    self.mark = chosen_mark
    @@human_mark = chosen_mark
  end

  def choose_name
    input = ''
    loop do
      input = gets.chomp
      skip
      break unless input.empty?
      prompt("Sorry, you must provide a player name")
    end
    input.strip
  end

  def set_name
    clear_screen
    prompt("Please enter your name:")
    skip
    self.name = choose_name
  end
end

class Computer < Players
  def settings
    set_mark
    set_name
  end

  def set_mark
    self.mark = (@@human_mark == 'X' ? 'O' : 'X')
  end

  def set_name
    self.name = Players::COMPUTER_NAMES.sample
  end
end

class Game
  include Displayable
  attr_accessor :human, :computer, :grid, :first_game, :starter

  def initialize
    initialize_players_points
  end

  def human_set_starter
    clear_screen
    # rubocop:disable Layout/LineLength
    prompt("Would yo like to start playing? (y)es or any key to leave the computer starts")
    # rubocop:enable Layout/LineLength
    skip
    option = gets.chomp.downcase
    @starter = option.start_with?('y') ? 'human' : 'computer'
  end

  def computer_set_starter
    clear_screen
    @starter = ['human', 'computer'].sample
    if @starter == 'human'
      prompt("Computer has decided that you start first")
    else
      prompt("Computer has decided to start playing first")
    end
    any_key_to_continue?
  end

  def set_starter
    who_sets = [1, 2].sample
    who_sets == 1 ? human_set_starter : computer_set_starter
  end

  def initialize_players_points
    @@human_won = 0
    @@computer_won = 0
  end

  FILES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  COLUMNS = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  DIAGONALS = [[3, 5, 7], [1, 5, 9]]
  WINNER_SQUARES = FILES + COLUMNS + DIAGONALS
  GRID_TITLE = "Current playing board"
  GRID_LENGTH = 49
  INITIAL_MARK = ' '

  def initialize_grid
    board = {}
    (1..9).each { |key| board[key] = INITIAL_MARK }
    board
  end

  def initialize_sequence(human, computer)
    human.sequence = []
    computer.sequence = []
  end

  # rubocop:disable Style/RedundantInterpolation
  def grid_heading
    puts "#{GRID_TITLE.center(GRID_LENGTH)}"
    skip
  end
  # rubocop:enable Style/RedundantInterpolation

  def puts_nbr(nbr)
    puts nbr.to_s.colorize(:light_yellow)
  end

  def display_row!(grid, row)
    sq0 = FILES[row][0]
    sq1 = FILES[row][1]
    sq2 = FILES[row][2]
    line1 = "|     |     |     |"
    line2 = "|  #{grid[sq0]}  |  #{grid[sq1]}  |  #{grid[sq2]}  |"
    line3 = "|     #{sq0}     #{sq1}     #{sq2}"
    puts line1.center(GRID_LENGTH)
    puts line2.center(GRID_LENGTH)
    puts line3.center(GRID_LENGTH)
  end

  def grid_separation
    puts "|-----|-----|-----|".center(GRID_LENGTH)
  end

  def display_grid!
    grid_heading
    display_row!(grid, 0)
    grid_separation
    display_row!(grid, 1)
    grid_separation
    display_row!(grid, 2)
    skip
  end

  def show_squares
    clear_screen
    prompt("Square numbers to mark")
    skip
    puts "       | 1 | 2 | 3 |"
    puts "       |---|---|---|"
    puts "       | 4 | 5 | 6 |"
    puts "       |---|---|---|"
    puts "       | 7 | 8 | 9 |"
    prompt("The first player who gets 5 points will be the game's winner")
    any_key_to_continue?
  end

  def grab_available_squares
    grid.select { |_, value| value == ' ' }.keys
  end

  def joinor(ary)
    left = ary[0..-2].join(', ')
    right = (ary.size == 1 ? ary.first.to_s : " or #{ary[-1]}")
    left + right
  end

  def available_squares
    available_array = grab_available_squares
    message = "Select one available square from:"
    prompt("#{message} #{joinor(available_array)}")
    skip
    available_array
  end

  def choose_move
    available_array = available_squares
    selection = ''
    loop do
      selection = gets.chomp
      # rubocop:disable Layout/LineLength
      break if selection.match?(/^\d$/) && available_array.include?(selection.to_i)
      # rubocop:enable Layout/LineLength
      prompt("Wrong selection, try again please")
    end
    selection
  end

  def human_marks!
    key = choose_move.to_i
    grid[key] = human.mark
    human.sequence << key
  end

  # rubocop:disable Layout/LineLength
  def ai_attack
    WINNER_SQUARES.each do |subarray|
      values_subarray = grid.values_at(*subarray)
      if values_subarray.count(computer.mark) == 2 && values_subarray.count(INITIAL_MARK) == 1
        values_subarray_key = values_subarray.index(INITIAL_MARK)
        return subarray[values_subarray_key]
      end
    end
    false
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  def ai_defense
    WINNER_SQUARES.each do |subarray|
      values_subarray = grid.values_at(*subarray)
      if values_subarray.count(human.mark) == 2 && values_subarray.count(INITIAL_MARK) == 1
        values_subarray_key = values_subarray.index(INITIAL_MARK)
        return subarray[values_subarray_key]
      end
    end
    false
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  def smart_computer_moves
    return ai_attack if ai_attack
    return ai_defense if ai_defense
    return grid[5] = computer.mark if grid[5] == INITIAL_MARK # trying to take position 5
    available_squares.sample # if nothing works, then it does a random move
  end
  # rubocop:enable Layout/LineLength

  def computer_marks!
    selection = smart_computer_moves
    grid[selection] = computer.mark
    computer.sequence << selection
  end

  def marking!(player)
    if player.instance_of?(Human)
      human_marks!
    else
      computer_marks!
    end
  end

  def human_won?
    winner = WINNER_SQUARES.any? do |subarray|
      subarray.all? { |key| grid[key] == human.mark }
    end
    if winner
      @@human_won += 1
      show_partial_standing unless @@human_won == 5
      return true
    end
    false
  end

  def computer_won?
    winner = WINNER_SQUARES.any? do |subarray|
      subarray.all? { |key| grid[key] == computer.mark }
    end
    if winner
      @@computer_won += 1
      show_partial_standing unless @@computer_won == 5
      return true
    end
    false
  end

  def tie?
    tie = grid.none? { |_, value| value == ' ' }
    if tie
      prompt("There's no winner, thist time it was a tie!")
      skip
      any_key_to_continue?
      return true
    end
    false
  end

  def separating_line
    puts "       |----------------|----------------|"
  end

  def names_line
    puts "       |#{human.name.center(16)}|#{computer.name.center(16)}|"
  end

  def marks_lines
    puts "       |#{human.mark.center(16)}|#{computer.mark.center(16)}|"
  end

  def lines_but_last
    markings = human.sequence.size
    (0...markings - 1).each do |index|
      # rubocop:disable Layout/LineLength
      puts "       |#{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
      # rubocop:enable Layout/LineLength
      separating_line
    end
  end

  def human_marking_lines
    lines_but_last
    puts "       |#{human.sequence.last.to_s.center(16)}|                |"
    separating_line
  end

  def computer_marking_lines
    markings = computer.sequence.size
    (0...markings).each do |index|
      # rubocop:disable Layout/LineLength
      puts "       |#{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
      # rubocop:enable Layout/LineLength
      separating_line
    end
  end

  def show_initial_marking
    skip
    puts "Marker Board".center(49)
    separating_line
    names_line
    marks_lines
    separating_line
  end

  def show_marking
    clear_screen
    show_initial_marking
    if human.sequence.size > computer.sequence.size
      human_marking_lines
    else
      computer_marking_lines
    end
    skip
  end

  def play_again?
    clear_screen
    @first_game = false
    prompt("Would you like to play again? (y)es or any key to quit")
    skip
    answer = gets.chomp.downcase
    answer.start_with?('y')
  end

  def display_end_message
    clear_screen
    prompt("Thanks for playing Tic Tac Toe. Good Bye!")
    skip
  end

  def display_welcome_message
    clear_screen
    prompt("Welcome to the Tic Tac Toe game")
    clear_screen if any_key_to_continue?
  end

  def play_init
    display_welcome_message
    show_squares
    @human = Human.new
    @computer = Computer.new
    set_starter
    @first_game = true
  end

  # rubocop:disable Layout/LineLength
  def initial_display(first_game)
    @grid = initialize_grid
    initialize_sequence(human, computer)
    clear_screen
    if !first_game
      prompt("Partial standing: #{human.name}: #{@@human_won} - #{computer.name}: #{@@computer_won}")
      skip
    end
    show_initial_marking
    skip
    display_grid!
  end
  # rubocop:enable Layout/LineLength

  def human_plays
    marking!(human)
    show_marking
    display_grid!
  end

  def computer_plays
    marking!(computer)
    show_marking
    display_grid!
  end

  # rubocop:disable Layout/LineLength
  def show_partial_standing
    skip
    puts "Partial Standings <<<<< #{human.name}: #{@@human_won} - #{computer.name}: #{@@computer_won} >>>>>"
    skip
    any_key_to_continue?
  end
  # rubocop:enable Layout/LineLength

  def someone_won_game?
    return false if @@human_won < 5 && @@computer_won < 5
    if @@human_won == 5
      prompt("#{human.name} is the game's winner!")
    else
      prompt("#{computer.name} is the game's winner!")
    end
    any_key_to_continue?
    initialize_players_points
    true
  end

  def human_starts
    loop do
      human_plays
      break if human_won?
      break if tie?
      computer_plays
      break if computer_won?
      break if tie?
    end
  end

  def computer_starts
    loop do
      computer_plays
      break if computer_won?
      break if tie?
      human_plays
      break if human_won?
      break if tie?
    end
  end

  def play
    play_init
    loop do
      loop do
        initial_display(first_game)
        starter == 'human' ? human_starts : computer_starts
        break if someone_won_game?
      end
      break unless play_again?
    end
    display_end_message
  end
end

Game.new.play
