#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c "

  echo -e "\n~~~ Welcome to Tangles Hair Salon ~~~\n"
MAIN_MENU() {

  #echo opening message with an argument or without
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo -e "\nHow may we help your hair?"
  fi
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME  
  do
  #menu options
  echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED  
  
  #check if service entered correctly, if so lookup customer
  if ! [[ "$SERVICE_ID_SELECTED" =~ ^[1-3]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME_CHOSEN=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo "What is your phone number?"
    read CUSTOMER_PHONE 

  
    #get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #if no record, ask for name and insert a new customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')");
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo 'What time would you like your '$(echo "$SERVICE_NAME_CHOSEN" | sed 's/^ *//')', '$(echo "$CUSTOMER_NAME" | sed 's/^ *//')'?'
    read SERVICE_TIME
    INSERT_SERVICE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo "$SERVICE_NAME_CHOSEN" | sed 's/^ *//') at $(echo "$SERVICE_TIME" | sed 's/^ *//'), $(echo "$CUSTOMER_NAME" | sed 's/^ *//')."
  fi

} 


MAIN_MENU
