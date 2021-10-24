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

module MasterMind
  class Player
    def initialize(name)
      @name = name
      @secret = Secret.new()
    end
  end

  class Secret
    def initialize
      @combo = []
    end

    def compare(guess)
      # Compare guess with @combo
      # For each element in @combo, check the same element in guess.
      #   Any exact match should push a "red peg" (correct position and element)
      # 
    end
  end

  class Game
    attr_reader :options

    def initialize(players)
      @guess = 0
      @players = players
    
      # Default game options
      @options = {slots: 4, characters: 6, blanks: false, duplicates: false}
    end

    def confirm_rules
      # Show the current rules, and ask if any changes to be made
    end

    def welcome_message
      # Send a welcome message displaying the rules.
    end

    def codemaster?
      # Determine which player is codemaster
      # That player will get to make a secret
    end

  end
end