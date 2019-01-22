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


public function addSubscriber(string repo_name, string subscriber_name) {


}

public function getSubscribers(string repo_name) returns string[] {
    var result = testDB->select("SELECT name FROM subscriber where repo='" + repo_name + "'", ());
    string[] subscribers = [];
    if (result is table< record {} >) {
        var jsonConversionRet = json.convert(result);

        if (jsonConversionRet is json) {

            foreach var i in 0..<jsonConversionRet.length() {
                io:println(jsonConversionRet[i].name);
                var name = string.convert(jsonConversionRet[i].name);
                if (name is string) {
                    subscribers[i] = name;
                }
            }
        }
        else {
            io:println("Error in table to json conversion");
        }
    }
    else {
        io:println("Select data from student table failed: "
                + <string>result.detail().message);
    }
    return subscribers;
}


