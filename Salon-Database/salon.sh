#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
# echo $($PSQL "TRUNCATE TABLE customers, appointments;")

MAIN() {
  echo "Please enter the service_id of the service you would like:"
  echo "$($PSQL "select service_id, name from services"  | sed 's/|/) /')"
  read SERVICE_ID_SELECTED

  SERVICE_NAME="$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")"
  if [[ -z $SERVICE_NAME ]];
  then
    # invalid service option
    MAIN
  else
    # prompt to enter phone number
    echo "Please enter a phone number:"
    read CUSTOMER_PHONE

    PHONE_CHECK=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    if [[ -z $PHONE_CHECK ]];
    then
      # register as a new customer
      echo "Please provide a name for the appointment:"
      read CUSTOMER_NAME
      
      REGISTER_USER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      if [[ $REGISTER_USER == 'INSERT 0 1' ]];
      then
        # success
        echo "Registered $CUSTOMER_NAME as a new customer"
      fi
    fi

    echo "Please enter a time to schedule your appointment:"
    read SERVICE_TIME

    CUSTOMER_ID_NAME=$($PSQL "select customer_id, name from customers where phone = '$CUSTOMER_PHONE'")
    IFS='|' read CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_ID_NAME"
    MAKE_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN