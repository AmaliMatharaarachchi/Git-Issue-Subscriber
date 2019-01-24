import ballerina/log;
import ballerina/test;
import ballerina/io;
import ballerina/http;

http:Client apiClientEndpoint = new("http://localhost:9090/git-issue-subscriber");

//correct
@test:Config
function testSubscribe() {
    io:println("test-> /subscribe");
    json payload = {
        repositoryOwner: "AmaliMatharaarachchi",
        repositoryName: "scrappy",
        email: "amali.14@cse.mrt.ac.lk"
    };
    http:Request req = new;
    req.setJsonPayload(payload);
    var subscribeResponse = apiClientEndpoint->post("/subscribe", req);
    if (subscribeResponse is http:Response) {
        var result = subscribeResponse.getJsonPayload();
        if (result is json) {
            test:assertEquals(result.status, 200);
        }
    }
}

//test with non existing repository name
@test:Config
function testNSubscribe() {
    io:println("test-> /subscribe");
    json payload = {
        repositoryOwner: "AmaliMatharaarachchi",
        repositoryName: "scappy",
        email: "amali.14@cse.mrt.ac.lk"
    };
    http:Request req = new;
    req.setJsonPayload(payload);
    var subscribeResponse = apiClientEndpoint->post("/subscribe", req);
    if (subscribeResponse is http:Response) {
        var result = subscribeResponse.getJsonPayload();
        if (result is json) {
            test:assertEquals(result.err, "Repository with name: " + <string>payload.repositoryOwner + "/" +
                        <string>payload.repositoryName + " is not found");
        }
    }
}

//correct
@test:Config
function testPostIssue() {
    io:println("test-> /issue");
    json payload = {
        repositoryOwner: "AmaliMatharaarachchi",
        repositoryName: "scrappy",
        issueTitle: "issue title 1",
        issueContent: "issue content"
    };
    http:Request req = new;
    req.setJsonPayload(payload);
    var subscribeResponse = apiClientEndpoint->post("/issue", req);
    if (subscribeResponse is http:Response) {
        var result = subscribeResponse.getJsonPayload();
        if (result is json) {
            test:assertEquals(result.status, 200);
        }
    }
}

