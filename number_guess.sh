#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NO_OF_GUESSES=1
#prompt for username
echo 'Enter your username:'
read USERNAME

#check database for user name
USER_ID=$($PSQL"SELECT user_id FROM user_details WHERE username = '"$USERNAME"'")

if [ -z $USER_ID ]
then
  #if new user then print create user in database and print welcome message
  GAMES_PLAYED=0
  ADD_USER=$($PSQL"INSERT INTO user_details(username) VALUES('$USERNAME');")
  echo 'Welcome, '$USERNAME'! It looks like this is your first time here.'
else
#if user name is in database than print welcome back message 
  GAMES_PLAYED=$($PSQL"SELECT games_played FROM user_details WHERE user_id = '$USER_ID';")
  BEST_GAME=$($PSQL"SELECT best_game FROM user_details WHERE user_id = '$USER_ID';")
  echo 'Welcome back, '$USERNAME'! You have played '$GAMES_PLAYED' games, and your best game took '$BEST_GAME' guesses.'
fi


#prompt to guess a number
echo 'Guess the secret number between 1 and 1000:'

#get input
read GUESS
#while input is not random number then do
until [[ $GUESS == $SECRET_NUMBER  ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi   
    #echo $SECRET_NUMBER
    read GUESS
    (( NO_OF_GUESSES++ ))
  else
    echo 'That is not an integer, guess again:'
    read GUESS
  fi

done

#print success and place game data into the database
echo 'You guessed it in '$NO_OF_GUESSES' tries. The secret number was '$SECRET_NUMBER'. Nice job!'

(( GAMES_PLAYED++ ))

if [[ $GAMES_PLAYED -eq 1 ]]
then
  BEST_GAME=$NO_OF_GUESSES
else
  if [[ $BEST_GAME -gt $NO_OF_GUESSES ]]
  then
  BEST_GAME=$NO_OF_GUESSES
  fi
fi

UPDATE_DATABASE=$($PSQL"UPDATE user_details SET games_played="$GAMES_PLAYED", best_game="$BEST_GAME" WHERE username='"$USERNAME"';")


