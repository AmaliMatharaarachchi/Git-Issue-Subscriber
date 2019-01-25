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
public function addSubscriber(string repositoryOwner, string repositoryName, string subscriberEmail) returns json {
    //insert record to mySQL database
    var status = testDB->update("INSERT INTO subscriber(email, repo_owner, repo_name)
                          values ('" + subscriberEmail + "','" + repositoryOwner + "','" + repositoryName + "')");
    json ret = { "status": 502 };

    if (status is int) {
        if (int.convert(status) == 1) {
            log:printInfo("subscriber : " + subscriberEmail + " and repository : " + repositoryOwner + "/" +
                    repositoryName + " is added to mySQL database successfully");
            ret.status = 200;

        }
        else {
            log:printError(" Error while adding subscriber :" + subscriberEmail + " and repository : " + repositoryOwner +
                    "/" + repositoryName + "to mySQL database. status returned : " + string.convert(status));
            ret["err"] = " Error while adding subscriber :" + subscriberEmail + " and repository : " + repositoryOwner +
                "/" + repositoryName + "to mySQL database.";
        }
    }
    else {
        log:printError(" Error : " + <string>status.detail().message);
        ret["err"] = <string>status.detail().message;
    }
    return ret;
}

# get subscribers from mysql database
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + return - Array of subscribers' email addresses
public function getSubscribers(string repositoryOwner, string repositoryName) returns json {
    //retrieve records from mySQL database
    string queryString = "SELECT email FROM SUBSCRIBER WHERE REPO_OWNER='"+ repositoryOwner+"' AND REPO_NAME='"+repositoryName+"'";
    var result = testDB->select(queryString, ());
    string[] subscribers = [];
    json ret = { "status": 200 };

    if (result is table< record {} >) {
        var jsonRecordsResult = json.convert(result);
        if (jsonRecordsResult is json) {
            //create array of emails
            foreach var i in 0..<jsonRecordsResult.length() {
                var email = string.convert(jsonRecordsResult[i].email);
                if (email is string) {
                    subscribers[i] = email;
                }
                else {
                    log:printError(" Error : " + <string>email.detail().message);
                    ret.status = 502;
                    ret["err"] = " Error : " + <string>email.detail().message;
                }
            }

        }
        else {
            log:printError(" Error : " + <string>jsonRecordsResult.detail().message);
            ret.status = 502;
            ret["err"] = " Error : " + <string>jsonRecordsResult.detail().message;
        }
    }
    else {
        log:printError(" Error : " + <string>result.detail().message);
        ret.status = 502;
        ret["err"] = " Error : " + <string>result.detail().message;
    }
    ret["subscribers"] = subscribers;
    return ret;
}


