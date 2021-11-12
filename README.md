# Ruby Command Line Mastermind
Another Ruby thing from The Odin Project! The most fun game of making and breaking codes! Are you ready to kick some butt?

# Instructions
This Ruby Mastermind supports playing against a computer as either the code maker or code breaker, as well as playing against another person.

The default rules are shown before the game begins, but you can also change the parameters if you so desire.

The source code is available on GitHub at https://github.com/crespire/mastermind

Play it online at https://replit.com/@crespire/Ruby-Mastermind

# TODO
Here are a few things I'd like to revisit in the future
* Move all the guess and code generation/fetching into the player class. This should simplify a lot of the turn keeping logic going on in the main Game class.
* Consider abstracting out the rules into their own class, so it becomes a reference to both the Game and Secret