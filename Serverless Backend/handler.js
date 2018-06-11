'use strict';

var AWS = require('aws-sdk');

// MARK: - Configuration of AWS Client
AWS.config.update({
   "region": "us-east-1",
  "endpoint": "http://dynamodb.us-east-1.amazonaws.com",
"accessKeyId": "yourAccessKeyId", "secretAccessKey": "yourSecretAccessKey"
});

var client = new AWS.DynamoDB.DocumentClient();

// Example of table name: "guitarrepair-mobilehub-8572585253-Orders"
var table = "myTableName";

/////////////////////////////////////////////////////////////////
////// MARK: - Create a new order for Orders table /////////////
///////////////////////////////////////////////////////////////
module.exports.createOrder = (event, context, callback) => {

var obj = JSON.parse(event.body);

var userId = obj.userId;
var name = obj.name;
var phone = obj.phone;
var repairNote = obj.repairNote;
var repairType = obj.repairType;
var repairPrice = obj.repairPrice;

 var params = {
    TableName: table,
    Item: {
    "userId": userId,
    "orderTime": getFormattedDate(),
    "name": name,
    "phone": phone,
    "repairNote": repairNote,
    "repairType": repairType,
    "repairPrice": repairPrice
   }
 };

 client.put(params, function(err, data){
  if(err){

     const fail = {
         isBase64Encoded: false,
            statusCode: 404,
             headers: {
            "Content-Type": "application/json"
            },
            body: JSON.stringify({
            "response": "Unable to add item. Error JSON"
            })
          }; 

      callback(null, fail);
      console.error("Unable to add item. Error JSON:", JSON.stringify(err, null, 2));
 
  } else {

     const succ = {
      isBase64Encoded: false,
            statusCode: 200,
              headers: {
            "Content-Type": "application/json"
            },
            body: JSON.stringify({
            "response": "Added item"
            })
          }; 

    callback(null, succ);

  }

 });

};

/////////////////////////////////////////////////////////////////
////// MARK: - Read user's orders from Orders table ////////////
///////////////////////////////////////////////////////////////
module.exports.readOrders = (event, context, callback) => {

var obj = JSON.parse(event.body);
var userId = obj.userId;

var params = {
    TableName : table,
    KeyConditionExpression: "#uid = :user_Id",
    ExpressionAttributeNames:{
        "#uid": "userId"
    },
    ExpressionAttributeValues: {
        ":user_Id": userId
    }
};

client.query(params,function(err, data){
    if(err) {

        const fail = {
           isBase64Encoded: false,
            statusCode: 404,
              headers: {
            "Content-Type": "application/json"
            },
            body: JSON.stringify({
            response: "Unable to read items. Error JSON"
            })
          }; 

      callback(err, fail);
    } else {

        const succ = {
           isBase64Encoded: false,
            statusCode: 200,
              headers: {
            "Content-Type": "application/json"
            },
            body:  JSON.stringify({
              items: data.Items
            })
    };

      callback(null, succ);
    }
  });
};

// MARK: - Gets a formatted date for each order created
function getFormattedDate()
{
  var today = new Date();

  var dd = today.getDate();
  var mm = today.getMonth() + 1;
  var yyyy = today.getFullYear();

  var formattedDate = mm + '/' + dd + '/' + yyyy; 

  return formattedDate;
}






