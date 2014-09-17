#! /bin/bash

    # dict
    # TODO: Provide libraries for this
    (cd dictionary/target/classes; java com/microserviceshack2/dictionary/Receiver & )
    # game board
    (cd game_board; coffee game_board_service & )
    # letters
    (cd letter_generator_highscores; gradle run & )
    # Highscores
    # TODO: Make this work - just wrong ATM.
    # (cd letter_generator_highscores/build/classes/main; java highscore/Main & )
    # scorer
    (cd scorer; gradle run & )
    # scorekeeper
    (cd scorekeeper; gradle run & )
    
