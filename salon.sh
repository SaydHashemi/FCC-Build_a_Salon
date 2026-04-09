#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  echo -e "\nWelcome to My Salon, please pick a service:\n"

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$AVAILABLE_SERVICES" | while IFS="|" read service_id name
  do
    echo "$service_id) $name"
  done

  echo

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU
  fi
}

MAIN_MENU

echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

#Checking if phone number is in our customers table
PHONE_CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

#If not:
if [[ -z $PHONE_CHECK ]]
then
  #Get customers name
  echo -e "\nEnter your name:"
  read CUSTOMER_NAME
  #Enter name and number into customers table
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
  #Enter time
  echo -e "\nEnter a time:"
  read SERVICE_TIME
  #Getting customer_id from new customer
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  #Inserting appointment if phone not in customers table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  #Final message
  CHOSEN_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  echo "I have put you down for a $CHOSEN_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
fi
