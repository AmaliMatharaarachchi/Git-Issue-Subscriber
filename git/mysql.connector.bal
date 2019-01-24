import ballerina/io;
import ballerina/mysql;
import ballerina/config;

mysql:Client testDB = new({
        host: config:getAsString("HOST"),
        port: config:getAsInt("PORT"),
        name: config:getAsString("NAME"),
        username: config:getAsString("USERNAME"),
        password: config:getAsString("PASSWORD"),
        poolOptions: { maximumPoolSize: 5 },
        dbOptions: { "useSSL": false }
    });


public function addSubscriber(string repositoryOwner, string repositoryName, string subscriber_name) returns boolean {
    var status = testDB->update("INSERT INTO subscriber(email, repo_owner, repo_name)
                          values ('" + subscriber_name + "','" + repositoryOwner + "','" + repositoryName + "')");
    if (status is int) {
        if (int.convert(status) == 1) {
            return true;
        }
    }
    else {
        io:println(" failed: " + <string>status.detail().message);

    }
    return false;
}

public function getSubscribers(string repositoryOwner, string repositoryName) returns string[] {
    string queryString="SELECT email FROM subscriber where repo_owner='" + repositoryOwner + "' and repo_name='"+repositoryName+"'";
    var result = testDB->select(queryString, ());
    string[] subscribers = [];
    if (result is table< record {} >) {
        var jsonConversionRet = json.convert(result);
        if (jsonConversionRet is json) {
            foreach var i in 0..<jsonConversionRet.length() {
                var email = string.convert(jsonConversionRet[i].email);
                if (email is string) {
                    subscribers[i] = email;
                }
            }
        }
    }
    return subscribers;
}


