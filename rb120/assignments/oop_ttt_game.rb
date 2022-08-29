require 'pry'

module Displayable
  def prompt(message)
    skip
    puts "> #{message}"
  end

  def clear_screen
    system 'clear'
  end

  def beep
    puts 7.chr
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
  attr_accessor :human, :computer, :grid, :first_game

  def initialize
    initialize_players_points
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

  def initialize_grid
    board = {}
    (1..9).each { |key| board[key] = ' ' }
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

  def display_grid!(grid)
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

  def get_available_squares(grid)
    grid.select { |_, value| value == ' ' }.keys
  end

  def joinor(ary)
    left = ary[0..-2].join(', ')
    right = (ary.size == 1 ? ary.first.to_s : " or #{ary[-1]}")
    left + right
  end

  def available_squares(grid)
    available_array = get_available_squares(grid)
    message = "Select one available square from:"
    prompt("#{message} #{joinor(available_array)}")
    skip
    available_array
  end

  def choose_move(grid)
    available_array = available_squares(grid)
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

  def human_marks!(grid, human)
    key = choose_move(grid).to_i
    grid[key] = human.mark
    human.sequence << key
  end

  def computer_marks!(grid, computer)
    selection = get_available_squares(grid).sample
    grid[selection] = computer.mark
    computer.sequence << selection
  end

  def marking!(player, grid)
    if player.instance_of?(Human)
      human_marks!(grid, player)
    else
      computer_marks!(grid, player)
    end
  end

  def human_won?(grid, human, computer)
    winner = WINNER_SQUARES.any? do |subarray|
      subarray.all? { |key| grid[key] == human.mark }
    end
    if winner
      @@human_won += 1
      return true
    end
    false
  end

  def computer_won?(grid, human, computer)
    winner = WINNER_SQUARES.any? do |subarray|
      subarray.all? { |key| grid[key] == computer.mark }
    end
    if winner
      @@computer_won += 1
      return true
    end
    false
  end

  def tie?(grid)
    tie = grid.none? { |_, value| value == ' ' }
    if tie
      prompt("There's no winner, thist time it was a tie!")
      skip
      return true
    end
    false
  end

  def separating_line
    puts "       |----------------|----------------|"
  end

  def names_line(human, computer)
    puts "       |#{human.name.center(16)}|#{computer.name.center(16)}|"
  end

  def marks_lines(human, computer)
    puts "       |#{human.mark.center(16)}|#{computer.mark.center(16)}|"
  end

  def lines_but_last(human, computer)
    markings = human.sequence.size
    (0...markings - 1).each do |index|
      # rubocop:disable Layout/LineLength
      puts "       |#{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
      # rubocop:enable Layout/LineLength
      separating_line
    end
  end

  def human_marking_lines(human, computer)
    lines_but_last(human, computer)
    puts "       |#{human.sequence.last.to_s.center(16)}|                |"
    separating_line
  end

  def computer_marking_lines(human, computer)
    markings = computer.sequence.size
    (0...markings).each do |index|
      # rubocop:disable Layout/LineLength
      puts "       |#{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
      # rubocop:enable Layout/LineLength
      separating_line
    end
  end

  def show_initial_marking(human, computer)
    skip
    puts "Marker Board".center(49)
    separating_line
    names_line(human, computer)
    marks_lines(human, computer)
    separating_line
  end

  def show_marking(human, computer)
    clear_screen
    show_initial_marking(human, computer)
    if human.sequence.size > computer.sequence.size
      human_marking_lines(human, computer)
    else
      computer_marking_lines(human, computer)
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
    @first_game = true
  end

  def initial_display(human, computer, first_game)
    @grid = initialize_grid
    initialize_sequence(human, computer)
    clear_screen
    if !first_game
      prompt("Partial standing: #{human.name}: #{@@human_won} - #{computer.name}: #{@@computer_won}")
      skip
    end
    show_initial_marking(human, computer)
    skip
    display_grid!(grid)
  end

  def human_plays(grid, human, computer)
    marking!(human, grid)
    show_marking(human, computer)
    display_grid!(grid)
  end

  def computer_plays(grid, human, computer)
    marking!(computer, grid)
    show_marking(human, computer)
    display_grid!(grid)
  end

  def show_partial_standing
    prompt("Partial standing: #{human.name}: #{@@human_won} - #{computer.name}: #{@@computer_won}")
    skip
    any_key_to_continue?
  end

  def someone_won_game?
    if @@human_won < 5 && @@computer_won < 5
      show_partial_standing
      return false
    end
    if @@human_won == 5
      prompt("#{human.name} is the game's winner!")
      any_key_to_continue?
    else
      prompt("#{computer.name} is the game's winner!")
      any_key_to_continue?
    end
    initialize_players_points
    true
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def play
    play_init
    loop do
      loop do
        initial_display(human, computer, first_game)
        loop do
          human_plays(grid, human, computer)
          break if human_won?(grid, human, computer)
          computer_plays(grid, human, computer)
          break if computer_won?(grid, human, computer)
          break if tie?(grid)
        end
        break if someone_won_game?
      end
      break unless play_again?
    end
    display_end_message
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end

Game.new.play
