import ballerina/mysql;
import ballerina/config;
import ballerina/log;

//create mySQL REST API client
mysql:Client testDB = new({
        host: config:getAsString("HOST"),
        port: config:getAsInt("PORT"),
        name: config:getAsString("NAME"),
        username: config:getAsString("USERNAME"),
        password: config:getAsString("PASSWORD"),
        poolOptions: { maximumPoolSize: 5 },
        dbOptions: { "useSSL": false }
    });

# add subscriber to mysql database
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, add subscriber to database is successful
public function addSubscriber(string repositoryOwner, string repositoryName, string subscriberEmail) returns boolean {
    //insert record to mySQL database
    var status = testDB->update("INSERT INTO subscriber(email, repo_owner, repo_name)
                          values ('" + subscriberEmail + "','" + repositoryOwner + "','" + repositoryName + "')");

    if (status is int) {
        if (int.convert(status) == 1) {
            log:printInfo("subscriber : " + subscriberEmail + " and repository : " + repositoryOwner + "/" +
                    repositoryName + " is added to mySQL database successfully");
            return true;
        }
        log:printError(" Error while adding subscriber :" + subscriberEmail + " and repository : " + repositoryOwner +
                "/" + repositoryName + "to mySQL database. status returned : " + string.convert(status));
    }
    else {
        log:printError(" Error : " + <string>status.detail().message);
    }
    return false;
}

# get subscribers from mysql database
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + return - Array of subscribers' email addresses
public function getSubscribers(string repositoryOwner, string repositoryName) returns string[] {
    //retrieve records from mySQL database
    string queryString = "SELECT email FROM subscriber where repo_owner='" + repositoryOwner + "' and repo_name='" +
        repositoryName + "'";
    var result = testDB->select(queryString, ());
    string[] subscribers = [];

    if (result is table< record {} >) {
        var jsonConversionRet = json.convert(result);
        if (jsonConversionRet is json) {
            //create array of emails
            foreach var i in 0..<jsonConversionRet.length() {
                var email = string.convert(jsonConversionRet[i].email);
                if (email is string) {
                    subscribers[i] = email;
                }
                else {
                    log:printError(" Error : " + <string>email.detail().message);
                }
            }
        }
        else {
            log:printError(" Error : " + <string>jsonConversionRet.detail().message);
        }
    }
    else {
        log:printError(" Error : " + <string>result.detail().message);
    }
    return subscribers;
}


