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
      @sequence = []
      settings
    end
  
  end
  
  class Human < Players

    def settings
      set_name
      set_mark
    end
  
    def set_mark
      clear_screen
      prompt("As your game's mark, would you want X or O?")
      skip
      option = ''
      loop do
        option = gets.chomp.upcase
        break if %w(X O).include? option
        prompt("Sorry, wrong option, just enter X or O")
      end
      self.mark = option
      @@human_mark = option
      any_key_to_continue?
    end
  
    def set_name
      clear_screen
      prompt("Please enter your name:")
      skip
      input = ''
      loop do
        input = gets.chomp
        skip
        break unless input.empty?
        prompt("Sorry, you must provide a player name")
      end
      self.name = input
      any_key_to_continue?
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

    attr_accessor :human, :computer, :grid
  
    def initialize_grid
      board = {}
      (1..9).each {|key| board[key] = ' '}
      board
    end
  
    def display_grid!(grid)
      puts "Current playing board".center(49)
      skip
      puts "|     |     |     |".center(49)
      puts "|  #{grid[1]}  |  #{grid[2]}  |  #{grid[3]}  |".center(49)
      puts "|     |     |     |".center(49)
      puts "|-----|-----|-----|".center(49)
      puts "|     |     |     |".center(49)
      puts "|  #{grid[4]}  |  #{grid[5]}  |  #{grid[6]}  |".center(49)
      puts "|     |     |     |".center(49)
      puts "|-----|-----|-----|".center(49)
      puts "|     |     |     |".center(49)
      puts "|  #{grid[7]}  |  #{grid[8]}  |  #{grid[9]}  |".center(49)
      puts "|     |     |     |".center(49)
      skip
    end
  
    def show_squares
      clear_screen
      prompt("To play you'll have to put your mark on one of the following square numbers:")
      skip
      puts "       | 1 | 2 | 3 |"
      puts "       |---|---|---|"
      puts "       | 4 | 5 | 6 |"
      puts "       |---|---|---|"
      puts "       | 7 | 8 | 9 |"
      any_key_to_continue?
    end
  
    def get_available_squares(grid)
      grid.select { |_,value| value == ' ' }.keys
    end
  
    def human_marks!(grid, human)
      available_array = get_available_squares(grid)
      prompt("Select one available square from: #{available_array}")
      selection = ''
      loop do
        selection = gets.chomp
        break if selection.match?(/^\d$/) && available_array.include?(selection.to_i)
        prompt("Wrong selection, try again please")
      end
      key = selection.to_i
      grid[key] = human.mark
      human.sequence << key
    end
  
    def computer_marks!(grid, computer)
      selection = get_available_squares.sample
      grid[selection] = computer.mark
      computer.sequence << selection
    end
  
    def marking!(player, grid)
      player.class == Human ? human_marks!(grid, player) : computer_marks!(grid, player)
  
    end
  
    def get_grid_state
  
    end
  
    def winner_or_tie?
  
    end
  
    def display_winner
  
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
  
    def human_marking_lines(human, computer)
      markings = human.sequence.size
      (0...markings-1).each do |index|
        puts "       |#{human.mark.center(16)}|#{computer.mark.center(16)}|"
        puts "       |#{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
        separating_line
      end
      puts "       | #{human.sequence.last}    |       |"
      separating_line
    end
  
    def computer_marking_lines(human, computer)
      markings = computer.sequence.size
      (0...markings).each do |index|
        puts "       | #{human.sequence[index].to_s.center(16)}|#{computer.sequence[index].to_s.center(16)}|"
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
      show_initial_marking(human, computer)
      human.sequence.size > computer.sequence.size ? human_marking_lines(human, computer) : computer_marking_lines(human, computer)
      skip
    end
  
    def play_again?
  
    end
  
    def display_end_message
  
    end
  
    def display_welcome_message
      clear_screen
      prompt("Welcome to the Tic Tac Toe game")
      clear_screen if any_key_to_continue?
    end
  
    def play
      display_welcome_message
      show_squares
      human = Human.new
      computer = Computer.new
      grid = initialize_grid
      loop do
        clear_screen
        show_initial_marking(human, computer)
        skip
        display_grid!(grid)
        loop do
          marking!(human, grid)
          show_marking(human, computer)
          display_grid!(grid)
          if winner_or_tie?
            display_winner
            break
          end
          marking!(computer, grid)
          show_marking(human, computer)
          display_grid_state
          if winner_or_tie?
            display_winner
            break
          end
        end
        break unless play_again?
      end
      display_end_message
    end
  end
  
  Game.new.play
    