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

  # Class to handle player actions
  class Player
    attr_accessor :secret

    def initialize(name)
      @name = name
      @secret = nil
    end
  end

  # Class to store the secret and comparisons to it
  class Secret
    def initialize
      @combo = []
    end

    def compare(guess)
      # Compare guess with @combo
      # Initalize a results array [0, 0]
      # For each element in @combo, check the same element in guess_copy.
      #   Any exact match should award an "exact match" point (correct position and element), and remove that element from guess_copy
      # For each element left in guess_copy, if the element is in @combo, then award a "match" point
      # return [0, 0]
    end
  end

  # Class to manage the interactions between players and the secret
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