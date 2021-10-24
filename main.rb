=begin
  Player
    * Has a secret
    * Has a name
    * Can make a guess
      * Take input, send to board
  Board
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
  end

  class Board
  end

  class Game
  end
end