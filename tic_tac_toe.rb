# frozen_string_literal: true

module TicTacToe
  LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]].freeze

  # This is Game class
  class Game
    def initialize(player_1_class, player_2_class)
      @board = Array.new(10)

      @current_player_id = 0
      @players = [player_1_class.new(self, 'X'), player_2_class.new(self, 'O')]
      puts "#{@current_player_id} goes first"
    end

    attr_reader :board, :current_player_id
  end
end
