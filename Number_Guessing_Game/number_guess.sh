#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUM_TO_GUESS=$(( ($RANDOM % 1000) + 1 ))
TRIES=0

PLAY_GAME() {
  local INPUT=$1
  local USERNAME=$2
  local NEW_USER_FLAG=$3

  if [[ ! $INPUT =~ ^[0-9]+$ ]];
  then
    # not an integer
    ((TRIES++))
    echo "That is not an integer, guess again:"
    read GUESS
    PLAY_GAME "$GUESS" "$USERNAME" "$NEW_USER_FLAG"
  else
    # is an integer, compare guess to secret number
    case 1 in
      $((GUESS > NUM_TO_GUESS)))
        ((TRIES++))
        echo "It's lower than that, guess again:"
        read GUESS
        PLAY_GAME "$GUESS" "$USERNAME" "$NEW_USER_FLAG"
        ;;
      $((GUESS < NUM_TO_GUESS)))
        ((TRIES++))
        echo "It's higher than that, guess again:"
        read GUESS
        PLAY_GAME "$GUESS" "$USERNAME" "$NEW_USER_FLAG"
        ;; 
      $((GUESS == NUM_TO_GUESS)))
        ((TRIES++))
        echo You guessed it in $TRIES tries. The secret number was $NUM_TO_GUESS. Nice job!

        if (( NEW_USER_FLAG == 1 ));
        then
          # new user; add them to database with 1 games played
          $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $TRIES)" >/dev/null
        else
          # existing user; increment games played and check if best_game can be replaced
          $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'" >/dev/null
          $PSQL "UPDATE users SET best_game = LEAST(best_game, $TRIES) WHERE username = '$USERNAME'" >/dev/null
        fi
        ;;
    esac

  fi
}

echo "Enter your username:"
read USERNAME

CHECK_USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")
if [[ -z $CHECK_USER ]];
then
  # not in database, new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  PLAY_GAME "$GUESS" "$USERNAME" 1
else
  # in database, existing user
  IFS='|' read USERNAME GAMES_PLAYED BEST_GAME <<< $CHECK_USER
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  PLAY_GAME "$GUESS" "$USERNAME" 0
fi
