# frozen_string_literal: true

module TicTacToe
  LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]].freeze

  # This is Game class
  class Game
    def initialize(player_1_class, player_2_class)
      @board = Array.new(10)

      @current_player_id = 0
      @players = [player_1_class.new(self, 'X'), player_2_class.new(self, 'O')]
      puts "#{@current_player} goes first"
    end

    attr_reader :board, :current_player_id

    def play
      loop do
        place_player_marker(current_player)

        if player_has_won?(current_player)
          puts "#{current_player} wins!"
          print_board
          return
        elsif board_full?
          puts "It's a draw!"
          print_board
          return
        end

        switch_players!
      end
    end

    def free_positions
      (1..9).select {|position| @board[position].nil?}
    end

    def place_player_marker(player)
      position = player.select_position!
      puts "#{player} selects #{player.marker} position #{position}"
      @board[position] = player.marker
    end

    def player_has_won?

    end

    def board_full?

    end

    def other_player_id

    end

    def switch_players!

    end

    def select_position!

    end
  end
end
