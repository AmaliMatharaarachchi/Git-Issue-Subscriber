import ballerina/io;
import ballerina/config;


//map<string[]> subscribers={"Amali":["g"]};

public function main() {
    //subscribe("Amali","list");
    string repo_name="wso2-ballerina/module-github";
    boolean j=isRepository(repo_name);
    string[] s= getSubscribers(repo_name);
    io:println("hello");
}

public function subscribe(string repo_name, string subscriber_name){

    if(isRepository(repo_name)){
        addSubscriber(repo_name,subscriber_name);
    }

}