#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PRINT_INFO() {
  local INFO_TO_EXTRACT="$1"
  IFS='|' read ATMC_NUM NAME SYMBOL TYPE ATMC_MASS MELT_POINT BOIL_POINT <<< "$INFO_TO_EXTRACT"
  echo "The element with atomic number $ATMC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATMC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
}

QUERY() {
  local ARG="$1"
  local TYPE_FLAG="$2"
  local WHERE_CLAUSE

  case "$TYPE_FLAG" in
    "num")
      WHERE_CLAUSE="atomic_number = $ARG"
      ;;
    "symbol")
      WHERE_CLAUSE="symbol = '$ARG'"
      ;;
    "name")
      WHERE_CLAUSE="name = '$ARG'"
      ;;
  esac

  RESULTS=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties LEFT JOIN elements USING(atomic_number) LEFT JOIN types USING(type_id) WHERE $WHERE_CLAUSE")
  if [[ -z $RESULTS ]];
  then
    # invalid
    echo "I could not find that element in the database."
  else
    # valid
    PRINT_INFO "$RESULTS"
  fi
}

if [[ ! $1 ]];
then
  echo "Please provide an element as an argument."
else
  if [[ "$1" =~ ^[0-9]+$ ]];
  then
    # its an integer meaning its atomic number
    QUERY "$1" 'num'
  else
    # either symbol or name
    # get length to determine which
    len=$(printf '%s' "$1" | wc -m)
    if (( "$len" <= 2 ));
    then
      # its a symbol
      QUERY "$1" 'symbol'
    elif (( "$len" <= 40 ));
    then
      # its a name
      QUERY "$1" 'name'
    fi
  fi
fi