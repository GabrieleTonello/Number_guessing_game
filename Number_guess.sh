#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((($RANDOM % 1000) + 1 ))

echo  "Enter your username:"

read USERNAME

# get user_id if exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME' ")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new user into db
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(name) values('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME' ")
else
  BEST_GAME=$($PSQL "SELECT numb_guesses FROM games WHERE user_id=$USER_ID ORDER BY numb_guesses LIMIT 1")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID") 
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
FOUND=0
EXPRESSION='^[0-9]+$'
while [[ $INPUT != $SECRET_NUMBER ]]
do
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
  read INPUT
  if [[ $INPUT =~ $EXPRESSION ]]
  then
    if [[  $INPUT -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      FOUND=1
    else
      if [[ $INPUT -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

if [[ $FOUND ]]
then
  INSERT_GAME=$($PSQL "INSERT INTO games (user_id, numb_guesses) VALUES($USER_ID , $NUMBER_OF_GUESSES) ")
fi

