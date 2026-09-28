#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat "games.csv" | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
  if [[ $WINNER != winner ]];
  then
    WIN_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # no team id found
    if [[ -z $WIN_TEAM_ID ]];
    then
      # add new team to db
      INSERT_WIN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WIN_RESULT == 'INSERT 0 1' ]];
      then
        echo "Inserted '$WINNER' into teams"
      fi
    fi

    OPP_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # no team id found
    if [[ -z $OPP_TEAM_ID ]];
    then
      # add new team to db
      INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPP_RESULT == 'INSERT 0 1' ]];
      then
        echo "Inserted '$OPPONENT' into teams"
      fi
    fi
  fi
done

cat "games.csv" | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
  if [[ $WINNER != winner ]];
  then
    # get winner_id
    WIN_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # get opponent_id
    OPP_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_TEAM_ID, $OPP_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    echo "Inserted $YEAR, '$ROUND', $WIN_TEAM_ID, $OPP_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS into games"
  fi
done