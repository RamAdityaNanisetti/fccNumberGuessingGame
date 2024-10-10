#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + RANDOM % 1000))
echo $RANDOM_NUMBER
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL " SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ ! -z $USER_ID ]]
then 
  USER_NAME=$($PSQL " SELECT username FROM users WHERE username='$USERNAME' ")
  GAMES_PLAYED=$($PSQL " SELECT games_played FROM users WHERE username='$USERNAME' ")
  BEST_GAME=$($PSQL " SELECT best_game FROM users WHERE username='$USERNAME' ")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS

COUNT=0
while true
do
  let COUNT++
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  elif [[ $GUESS == $RANDOM_NUMBER ]]
  then
    if [[ -z $USER_ID ]]
    then
      echo "$($PSQL " INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $COUNT) ")"
    else
      let GAMES_PLAYED++
      echo "$($PSQL " UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$USERNAME' ")"
      if [[ $BEST_GAME > $COUNT ]]
      then 
        echo "$($PSQL " UPDATE users SET best_game = $COUNT WHERE username='$USERNAME' ")"
      fi
    fi
    echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    break
  elif [[ $GUESS < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
  fi
done


