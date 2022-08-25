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
  
    def initialize
      @sequence = []
      @human_mark = ''
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

    attr_reader :human_mark
  
    def settings
      set_mark
      set_name
    end

    def set_mark
      self.mark = (human_mark == 'X' ?  'O' : 'X')
    end
  
    def set_name
      self.name = Players::COMPUTER_NAMES.sample
    end
  
  end
  
  class Game
    include Displayable

    attr_accessor :human, :computer
  
    def initialize_grid
      board = {}
      (1..9).each {|key| board[key] = ' '}
      board
    end
  
    def display_grid!(grid)
      prompt("        Current board")
      skip
      puts "       |     |     |     |"
      puts "       |  #{grid[1]}  |  #{grid[2]}  |  #{grid[3]}  |"
      puts "       |     |     |     |"
      puts "       |-----|-----|-----|"
      puts "       |     |     |     |"
      puts "       |  #{grid[4]}  |  #{grid[5]}  |  #{grid[6]}  |"
      puts "       |     |     |     |"
      puts "       |-----|-----|-----|"
      puts "       |     |     |     |"
      puts "       |  #{grid[7]}  |  #{grid[8]}  |  #{grid[9]}  |"
      puts "       |     |     |     |"
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
      grid.keys.select { |_,value| value == ' ' }
    end
  
    def human_moves!(grid)
      available_array = get_available_squares(grid)
      prompt("Select one available square from: #{available_array}")
      selection = ''
      loop do
        selection = gets.chomp
        break if selection.match?(/^\d$/) && available_array.include?(selection)
        prompt("Wrong selection, try again please")
      end
      grid[selection] = self.mark
      self.sequence << selection
    end
  
    def computer_marks!(grid)
      selection = get_available_squares.sample
      grid[selection] = self.mark
      self.sequence << selection
    end
  
    def marking!(player, grid)
      player.class = Human ? human_marks!(grid) : computer_marks!(grid)
  
    end
  
    def get_grid_state
  
    end
  
    def winner_or_tie?
  
    end
  
    def display_winner
  
    end
  
    def separating_line
      puts "|----------------|----------------|"
    end
  
    def names_line
      puts "| #{human.name}    | #{computer.name}      |"
    end
  
    def marks_lines
      puts "| #{human.mark}    | #{computer.mark}      |"
    end
  
    def human_marking_line
      markings = human.sequence.size
      (0...markings-1).each do |index|
        puts "| #{human.sequence[index]}    |  #{computer.sequence[index]}     |"
        separating_line
      end
      puts "| #{human.sequence.last}    |       |"
      separating_line
    end
  
    def computer_marking_line
      markings = computer.sequence.size
      (0...markings).each do |index|
        puts "| #{human.sequence[index]}    |  #{computer.sequence[index]}     |"
        separating_line
      end
    end
      
    def show_marking(player)
      separating_line
      names_line
      marks_lines
      separating_line
      player.class == Human ? human_marking_line : computer_marking_line
  
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
      loop do
        grid = initialize_grid
        clear_screen 
        display_grid!(grid)
        loop do
          marking!(human, grid)
          show_marking(human)
          display_grid!(grid)
          if winner_or_tie?
            display_winner
            break
          end
          marking!(computer, grid)
          show_marking
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
    