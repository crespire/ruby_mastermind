=begin
  Player
    * Has a name
    * Optionally, has secret
    * Can make a guess
      * Take input, send to board
  Secret
    * Evaluates guesses against the secret
    * Provides feedback on the guess.
  GameRound
    * Sets secret validation after asking
      * Default case should be: 4 slots, taking 1 - 6, no blanks and no duplicates
      * Additional options
        * More slots
        * Are blanks allowed? (Add 0 to options)
        * Are duplicates allowed? (Able to enter same number twice)
    * Keeps track of guesses
    * Keeps track of which player is guessing
=end

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
      puts "Here are the current rules for the game."
      puts "The code must be %{length} characters in length, and there are %{characters} options for each slot." % @options
      puts "The code #{@options[:blanks] ? "can" : "can't"} contain any blanks."
      puts "The code #{@options[:duplicates] ? "can" : "can't"} contain duplicates."
      puts "The codebreaker has #{@options[:turns]} tries to break the code."
    end

    def change_rules
      # Allow players to change the rules - work on this after the main game is complete.
    end

    def codemaster?
      # Require input
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
      # Computer guess.
      puts "The computer is making a guess..."
      if previous.nil?
        guess = [1, 1, 2, 2]
        base = @options[:blanks] ? 0 : 1
        start_num = (base.to_s * @options[:length]).to_i
        end_num = start_num * @options[:characters].to_i
        @possible = (start_num..end_num).to_a
      else
        # use hints
        last = Secret.new(previous)
        puts "Last guess: #{last} and feedback #{hints}, current possibilities: #{@possible.length}"
        @possible.filter! do |code|
          comp_ar = last.compare(code.to_s.chars.map(&:to_i))
          puts "#{(comp_ar <=> hints) >= 0 ? "keep" : "discard"} code: #{code}, got #{comp_ar} vs #{hints}"
          sleep(0.05)
          code if (comp_ar <=> hints) >= 0
        end
        puts "Filtered possibilities: #{@possible.length}, contains answer: #{@possible.include?(@players[@codemaster].secret.to_i)}"

        guess = @possible.shift.to_s.chars.map(&:to_i) # I think I'm missing something here or in my filter. Sometimes it's not reducing the possibilties
      end
      puts "Guess is: #{guess}"
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

      # system("clear") || system("cls")

      start = @options[:blanks] ? 0 : 1
      dup = @options[:duplicates] ? '' : 'no '
      puts "Remember, the code is #{@options[:length]} characters long and can entries are between #{start} and #{@options[:characters]}. The code has #{dup}duplicate entries."
      broken = false
      guess = nil
      result = nil

      @options[:turns].times do |i|
        # Run the rounds
        guess = @codemaster.zero? ? get_guess : generate_guess(guess, result)
        result = secret.compare(guess)
        if result[0] == secret.length
          broken = true
          puts "You won! You took #{i+1} turns to guess the code, which was #{secret}."
          break
        else
          puts "#{i+1}: You got #{result[0]} exact matches, and there were #{result[1]} additional matches, but not in the right place."
        end
        print "Press key to continue"
        gets.chomp
      end

      puts "You didn't break the code! The code was #{secret}." unless broken

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

# Testing guess compare
#code = MasterMind::Secret.new([4, 3, 6, 2])
#p code.compare([2,2,2,2])
#p code.compare([2,6,3,4])
#p code.compare([4,1,2,6])
#p code.compare([3,3,3,3])
#p code.compare([4,3,6,2])
#p code.length
 
#code2 = MasterMind::Secret.new([5,6,1,3])
# p code2.compare([1,1,2,2])
# p code2.compare([1,1,1,1])

#code3 = MasterMind::Secret.new([1,2,1,5])
#p code3.compare([1,1,2,2]) #Expect [1, 2]
#p code3.compare([2,2,1,1]) #Expect [2, 1]
#p code3.compare([1,2,3,4]) #Expect [2, 0]