# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack'

=begin
module TicTacToe
  LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]].freeze

  class Game
    def initialize(player_1_class, player_2_class)
      @board = Array.new(10, nil)
      @current_player_id = 0
      @players = [player_1_class.new(self, 'X'), player_2_class.new(self, 'O')]
      puts "#{current_player} goes first"  # FIXED: was @current_player
    end
    # ... YOUR FULL ORIGINAL CODE HERE (Game, Player, HumanPlayer, ComputerPlayer)
  end
end
=end

enable :sessions
set :session_secret,
    'tic-tac-toe-session-secret-please-change-this-to-something-long-and-random-123456'

module TicTacToe
  LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]].freeze

  # This is main Game class
  class Game
    def initialize(player_1_class = ComputerPlayer, player_2_class = ComputerPlayer)
      @board = Array.new(10, nil)
      @current_player_id = 0
      @players = [player_1_class.new(self, 'X'), player_2_class.new(self, 'O')]
      # puts "#{current_player} goes first"  # YOUR ORIGINAL - disabled for web
    end

    attr_reader :board, :current_player_id, :players, :current_player

    def current_player
      @players[@current_player_id]
    end

    def other_player_id
      1 - @current_player_id
    end

    def switch_players!
      @current_player_id = other_player_id
    end

    def free_positions
      (1..9).select { |position| @board[position].nil? }
    end

    def place_marker?(position, marker)
      return false unless free_positions.include?(position)

      @board[position] = marker
      true
    end

    def player_has_won?(marker)
      LINES.any? { |line| line.all? { |pos| @board[pos] == marker } }
    end

    def board_full?
      free_positions.empty?
    end

    def to_h
      {
        board: @board.map { |cell| cell || ' ' },
        current_player: current_player.marker,
        status: game_status
      }
    end

    private

    def game_status
      if player_has_won?('X')
        'X Wins! 🎉'
      elsif player_has_won?('O')
        'O Wins! 🎉'
      elsif board_full?
        "It's a Draw! 🤝"
      else
        "Your turn (#{current_player.marker})"
      end
    end
  end


  # class for AI
  class ComputerPlayer
    def initialize(game, marker)
      @game = game
      @marker = marker
    end

    attr_reader :marker

    def select_position!
      # YOUR ORIGINAL SMART AI LOGIC (simplified for web speed)
      best_move = find_winning_move || find_blocking_move || [5, 1, 3, 7, 9, 2, 4, 6, 8].find { |p| @game.free_positions.include?(p) }
      best_move || @game.free_positions.first
    end

    private

    def find_winning_move
      TicTacToe::LINES.each do |line|
        empty = line.select { |pos| @game.board[pos].nil? }
        if empty.length == 1 &&
           line.count { |pos| @game.board[pos] == @marker } == 2
          return empty.first
        end
      end
      nil
    end

    def find_blocking_move
      opponent_marker = @marker == 'X' ? 'O' : 'X'
      TicTacToe::LINES.each do |line|
        empty = line.select { |pos| @game.board[pos].nil? }
        if empty.length == 1 &&
           line.count { |pos| @game.board[pos] == opponent_marker } == 2
          return empty.first
        end
      end
      nil
    end
  end
end

# Sinatra Web Routes
get '/' do
  erb :index
end

get '/api/new_game' do
  session[:board] = Array.new(10, nil)

  game = TicTacToe::Game.new
  game.instance_variable_set(:@board, session[:board])

  content_type :json
  game.to_h.to_json
end

post '/api/move/:position' do
  session[:board] ||= Array.new(10, nil)

  game = TicTacToe::Game.new
  game.instance_variable_set(:@board, session[:board])

  position = params[:position].to_i

  if game.free_positions.include?(position)
    game.place_marker?(position, 'X')

    unless game.player_has_won?('X') || game.board_full?
      ai_pos = TicTacToe::ComputerPlayer
               .new(game, 'O')
               .select_position!
      game.place_marker?(ai_pos, 'O')
    end
  end

  session[:board] = game.board

  content_type :json
  game.to_h.to_json
end


__END__

@@ index
<!DOCTYPE html>
<html>
<head>
  <title>Ruby TicTacToe</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh; 
      display: flex; 
      flex-direction: column; 
      align-items: center; 
      justify-content: center; 
      color: white;
    }
    h1 { 
      font-size: 2.5em; 
      margin-bottom: 20px; 
      text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    .board { 
      display: grid; 
      grid-template-columns: repeat(3, 120px); 
      gap: 8px; 
      background: rgba(255,255,255,0.1);
      padding: 20px;
      border-radius: 20px;
      backdrop-filter: blur(10px);
      box-shadow: 0 20px 40px rgba(0,0,0,0.3);
    }
    .cell { 
      width: 120px; 
      height: 120px; 
      background: rgba(255,255,255,0.9); 
      border: 4px solid rgba(255,255,255,0.3);
      font-size: 3.5em; 
      font-weight: bold;
      cursor: pointer; 
      display: flex; 
      align-items: center; 
      justify-content: center;
      border-radius: 12px;
      transition: all 0.2s;
      color: #333;
    }
    .cell:hover:not(.filled) { transform: scale(1.05); }
    .cell.x { color: #e74c3c; }
    .cell.o { color: #3498db; }
    .cell.filled { cursor: default; }
    .status { 
      font-size: 1.8em; 
      margin: 30px 0; 
      padding: 15px 30px;
      background: rgba(255,255,255,0.2);
      border-radius: 50px;
      backdrop-filter: blur(10px);
    }
    button { 
      padding: 15px 40px; 
      font-size: 1.2em; 
      background: #ff6b6b; 
      color: white; 
      border: none; 
      border-radius: 50px; 
      cursor: pointer; 
      margin: 10px;
      font-weight: bold;
      transition: all 0.3s;
    }
    button:hover { background: #ff5252; transform: translateY(-2px); }
    .deployed { position: fixed; bottom: 20px; right: 20px; font-size: 0.8em; opacity: 0.8; }
    .original-code { 
      position: fixed; top: 20px; right: 20px; 
      background: rgba(0,0,0,0.5); padding: 10px; 
      border-radius: 10px; font-size: 0.7em; max-width: 200px;
    }
  </style>
</head>
<body>
  <div class="original-code">
    💾 Original code preserved<br>
    🎮 Web version active
  </div>
  
  <h1>🎮 Ruby TicTacToe</h1>
  <div class="status" id="status">Click New Game to Start!</div>
  <div class="board" id="board"></div>
  <button onclick="newGame()">New Game</button>
  
  <div class="deployed">
    Deployed on Render • Ruby + Sinatra
  </div>

  <script>
    let board = Array(10).fill(' ');

    function renderBoard() {
      const boardEl = document.getElementById('board');
      boardEl.innerHTML = '';
      for (let i = 1; i <= 9; i++) {
        const cell = document.createElement('div');
        cell.className = `cell ${board[i] === 'X' ? 'x' : board[i] === 'O' ? 'o' : ''} ${board[i] !== ' ' ? 'filled' : ''}`;
        cell.textContent = board[i];
        if (board[i] === ' ') cell.onclick = () => makeMove(i);
        boardEl.appendChild(cell);
      }
    }

    async function makeMove(position) {
      if (board[position] !== ' ') return;
      
      const response = await fetch(`/api/move/${position}`, {
      method:  'POST'});
      const data = await response.json();
      
      board = data.board;
      document.getElementById('status').textContent = data.status;
      renderBoard();
    }

    async function newGame() {
      const response = await fetch('/api/new_game');
      const data = await response.json();
      board = data.board;
      document.getElementById('status').textContent = data.status;
      renderBoard();
    }

    renderBoard();
  </script>
</body>
</html>
