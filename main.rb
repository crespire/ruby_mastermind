=begin
  Player
    * Has a secret
    * Has a name
    * Can make a guess
      * Take input, send to board
  Secret
    * Evaluates guesses against the secret
    * Provides feedback on the guess.
  GameRound
    * Sets secret validation after asking
      * Default case should be: 4 slots, taking 1 - 6
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

  end
end