# frozen_string_literal: true

module MasterMind

  # Class to handle player actions
  class Player
    attr_accessor :secret, :name, :codemaster

    def initialize(name)
      @name = name
      @secret = nil
      @codemaster = false
    end
  end

  # Class to store the secret and comparisons to it
  class Secret
    def initialize(combination)
      @combo = combination
    end

    def length
      @combo.length
    end

    def to_s
      @combo.join('-')
    end

    def to_i
      @combo.join.to_i
    end

    def compare(guess)
      results = [0, 0]
      combo_copy = @combo.dup
      guess_copy = guess.dup

      # Checks position/value match
      @combo.each_with_index do |element, index|
        if guess[index] == element
          results[0] += 1
          guess_copy[index] = nil
          combo_copy[index] = nil
        end
      end

      # Checks value match
      guess_copy.uniq!      
      guess_copy.each do |element|
        results[1] += combo_copy.count(element) unless element.nil?
      end

      results
    end
  end

  # Class to manage the interactions between players and the secret
  class Game
    attr_reader :options

    def initialize()
      @players = []
      @codemaster = 0
      @use_comp = nil
    
      # Default game options
      @options = {turns: 12, length: 4, characters: 6, blanks: false, duplicates: false}
      @options.default = ''
    end

    def setup
      # Get player names, and create players array
      # Send a welcome message displaying the rules.
      # Ask if players want to change the rules

      puts "Welcome to Mastermind!"
      
      valid = false
      until valid do
        print "How many players are there today? "
        answer = gets.chomp!.to_i
        @use_comp = answer == 1 ? true : false
        valid = answer.between?(1,2)
      end

      @players.push(Player.new('Computer'))

      print "Let's get set up! Player 1, please enter your name: "
      name = gets.chomp!
      @players.push(Player.new(name))
      puts "Hello #{name}, welcome to Mastermind!"

      if !@use_comp
        print "Player 2, please enter your name: "
        name = gets.chomp!
        @players.push(Player.new(name))
        puts "Welcome, #{name}!"
      end

      puts "Let's get started!"
      change_rules?

    end

    def change_rules?
      # Allow players to change the rules
      puts "Here are the current rules for the game."
      puts "The code must be %{length} characters in length, and there are %{characters} options for each slot." % @options
      puts "The code #{@options[:blanks] ? "can" : "can't"} contain any blanks."
      puts "The code #{@options[:duplicates] ? "can" : "can't"} contain duplicates."
      puts "The codebreaker has #{@options[:turns]} tries to break the code."
    end

    def codemaster?
      valid = false
      until valid do
        puts "Player 0: Computer" if @use_comp
        lower_bound = @use_comp ? 0 : 1
        @players.each_with_index { |e, i| puts "Player #{i}: #{e.name}\n" if i > 0  }
        print "Which player will be the code master? "
        @codemaster = gets.chomp!.to_i
        valid = @codemaster.between?(lower_bound, (@players.length - 1))
      end
      puts "#{@players[@codemaster].name} is the codemaster!"
      @players[@codemaster].codemaster=true

      if @codemaster.zero? && @use_comp then
        generate_code
      else
        get_code
      end
    end

    def generate_code
      valid = false
      until valid do
        gen_code = @options[:length].times.map { rand(1..@options[:characters]) } 
        valid = valid_code?(gen_code)
      end
      @players[@codemaster].secret=(Secret.new(gen_code))
    end

    def get_code
      valid = false
      until valid do
        print "#{@players[@codemaster].name}, please provide a code: "
        code = gets.chomp.chars.map { |c| c.to_i }
        valid = valid_code?(code)
      end
      @players[@codemaster].secret=(Secret.new(code))
    end

    def get_guess
      # Get a guess. Check the secret to make sure it's valid.
      valid = false

      name = @use_comp ? @players[1].name : @players[3-@codemaster].name

      until valid do
        print "#{name}, please enter a guess: "
        guess = gets.chomp!.chars.map { |c| c.to_i }
        valid = valid_guess?(guess)
      end
      guess
    end

    def generate_guess(previous = nil, hints = nil)
      puts "The computer is making a guess..."
      if previous.nil?
        guess = [1, 1, 2, 2]
        base = @options[:blanks] ? 0 : 1
        start_num = (base.to_s * @options[:length]).to_i
        end_num = start_num * @options[:characters].to_i
        @possible = (start_num..end_num).to_a
      else
        @possible.filter! { |code| code if (Secret.new(code.to_s.chars.map(&:to_i)).compare(previous) <=> hints) == 0 }
        guess = @possible.shift.to_s.chars.map(&:to_i)
      end
      guess
    end

    def valid_code?(code)
      # Checks if the code provided is within the rules.
      return false unless right_length?(code)
      return false unless in_bounds?(code)
      return false if has_duplicates?(code) && !@options[:duplicates]
      
      true
    end

    def valid_guess?(code)
      # Checks if the code provided is the right length only.
      return false unless right_length?(code)
      
      true
    end

    def play_round
      codemaster?

      secret = @players[@codemaster].secret

      system("clear") || system("cls")

      start = @options[:blanks] ? 0 : 1
      dup = @options[:duplicates] ? '' : 'no '
      puts "Remember, the code is #{@options[:length]} characters long and can entries are between #{start} and #{@options[:characters]}. The code has #{dup}duplicate entries."
      broken = false
      guess = nil
      result = nil

      @options[:turns].times do |i|
        guess = @codemaster.zero? ? generate_guess(guess, result) : get_guess
        result = secret.compare(guess)
        if result[0] == secret.length
          broken = true
          puts "Game over! Cracking the code took #{i+1} turns. The code was: #{secret}."
          break
        else
          puts "#{i+1}: There were #{result[0]} exact matches, and there were #{result[1]} additional matches in the wrong places."
        end
      end

      puts "The code was too strong! Try again another time. The code was #{secret}." unless broken

      valid = false
      until valid do
        print "Would you like to play again? (y/n) "
        ans = gets.chomp!
        valid = ['y', 'n'].include?(ans)
      end

      if ans == 'y'
        reset
      else
        exit
      end
    end

    private
    def reset
      @codemaster = 0
      @players = []
      setup
      play_round
    end

    def right_length?(code)
      code.length == @options[:length]
    end

    def in_bounds?(code)
      lower = @options[:blanks] ? 0 : 1
      code.all? { |digit| digit.between?(lower, @options[:characters]) }
    end

    def has_duplicates?(code)
      code.length != code.uniq.length
    end
  end
end

mstr = MasterMind::Game.new()
mstr.setup
mstr.play_round