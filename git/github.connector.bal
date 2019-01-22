import ballerina/config;
import ballerina/http;
import ballerina/io;
import wso2/github4;

github4:GitHubConfiguration gitHubConfig = {
     clientConfig: {
         auth: {
             scheme: http:OAUTH2,
             accessToken: config:getAsString("GITHUB_TOKEN")
         }
     }
 };
 
github4:Client githubClient = new(gitHubConfig);

public function isRepository(string repo_name) returns boolean{
    github4:Repository|error result = githubClient->getRepository(repo_name);
    if (result is github4:Repository) {
        //io:println(result);
        return true;
    } else {
        io:println("Error occurred on getRepository(): ", result);
    }
    return false;
}

