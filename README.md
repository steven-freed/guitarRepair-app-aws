# Guitar Repair iOS App
This app is a tutorial on how to connect a iOS Swift mobile app to Amazon Web Service. It goes through creating repair orders and reading guitar repair orders. The backend of the app uses AWS Lambda and API-Gateway to create and read repairs from DynamoDB.

## Outline for Architecture of App
...

    1. Start iOS app with Xcode and start an app in AWS Mobile Hub console
    2. Adjust the settings to your requirements 
    I use Dynamo with the following Schema
    ![Alt text](/images/db.png?raw=true "Dynamo Schema")
    
    3. Download the awsconfiguration.json (Each time you make changes to AWS) 
    4. Modify your plist file in Xcode with the following
    ![Alt text](/images/plist.png?raw=true "Plist Configuration")
    
    5. Add API-Gateway endpoints
    ![Alt text](/images/paths.png?raw=true "API-Gateway")
    6. Use IAM Authentication
       For this to work you need to go to IAM roles and use the following permission for the role associated with your apps Cognito federated identity pool authenticated user
    ![Alt text](/images/fedId.png?raw=true "Federated Identity Auth Role")
    
    Add inline policy for role, switch to JSON editing and copy and paste the following
    {
    "Version": "2012-10-17",
    "Statement": [
    {
    "Action": [
    "execute-api:Invoke"
    ],
    "Resource": "arn:aws:execute-api:us-east-1:793962556423:dddf9grlp2/*/*/*",
    "Effect": "Allow"
    }
    ]
    }
    
    ![Alt text](/images/requestType.png?raw=true "API-Gateway Auth")
    
    7. Go to API-Gateway and set the Integration Request to Lambda Proxy (this lets us shape the response however we want, with a non-proxy lambda we use models for our data in the AWS console. Proxy allows for easy manipulation of headers, status codes, and body of our request so if the data were passing changes the api still works.)
      Lambda Proxy = Backend code controls response and request
      Lambda = aws console json models control response and request
      
      ![Alt text](/images/proxy.png?raw=true "API-Gateway Auth")
...

## Outline for Backend of App
...

    1. Open a terminal and make sure you have nodejs and npm installed
    2. Install the Serverless Framework to upload functions to AWS Lambda in the terminal by using 
    ~$ npm install -g serverless
    3. Make a directory for your project
    4. Go to that directory
    5. Generate a Serverless template using
    ~$ serverless create -t aws-nodejs
    Install the AWS SDK for doing CRUD operations on DynamoDB
    ~$ npm install aws-sdk
    6. Now to link your code with AWS Lambda and AWS API-Gateway, go to AWS console and click your name, then security credentials
    ![Alt text](/images/security.png?raw=true "Security Creds")

    click 'create new access key', download the key file and store somewhere safe.
    
    * NOTE: 
    QUICK START - This way gives anyone with your keys full access to your AWS account
    BETTER WAY - Create an IAM user with limited permissions and use their keys
    
    7. Go to terminal then directory of your project, type
    ~$ serverless config credentials --provider aws --key yourKey --secret yourSecret
    8. Upload your functions using the command
    ~$ serverless deploy
    or for short
    ~$ sls deploy
    9. In '/Serverless Backend/handler.js' use those keys at the top of the file where it asks for keys. You may also create environment variables in the lambda console to keep these keys more secure.
    

...


