import ballerina/http;
import ballerina/log;

//todo -> errors. response status. handle untaint. error handle request containing all required, handle duplicates in database
listener http:Listener httpListener = new(config:getAsInt("SERVICE_PORT"));

//GitHub issue subscriber REST service
@http:ServiceConfig {
    basePath: "/git-issue-subscriber"
}
service IssueSubscriber on httpListener {
    //endpoint to subcribe to a GitHub repository-> /subscribe
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/subscribe"
    }
    resource function subscribe(http:Caller caller, http:Request request) {
        var subscribeRequest = request.getJsonPayload();

        if (subscribeRequest is json) {
            string repositoryOwner = untaint <string>subscribeRequest.repositoryOwner;
            string repositoryName = untaint <string>subscribeRequest.repositoryName;
            string email = untaint <string>subscribeRequest.email;
            json response = setSubscriber(repositoryOwner, repositoryName, email);

            if (response.status == 200) {
                log:printInfo("successful! subscribed to repository " + repositoryName);
            }
            else {
                log:printError("Error! failed to subscribe to " + repositoryName);
            }
            var result = caller->respond(untaint response);
        }
        else {
            http:Response response = new;
            response.setPayload("Error! subscribe request should be in JSON format.");
            var result = caller->respond(response);
        }

    }

    //endpoint to post a issue in GitHub repository-> /issue
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/issue"
    }
    resource function postIssue(http:Caller caller, http:Request request) {
        var issueRequest = request.getJsonPayload();

        if (issueRequest is json) {
            string repositoryOwner = untaint <string>issueRequest.repositoryOwner;
            string repositoryName = untaint <string>issueRequest.repositoryName;
            string issueTitle = untaint <string>issueRequest.issueTitle;
            string issueContent = untaint <string>issueRequest.issueContent;
            json response = setIssue(repositoryOwner, repositoryName, issueTitle, issueContent);

            if (response.status == 200) {
                log:printInfo("successful! posted issue to " + repositoryName);
            }
            else {
                log:printError("Error! failed to post issue to " + repositoryName);
            }
            var result = caller->respond(untaint response);
        }
        else {
            http:Response response = new;
            response.setPayload("Error! issue post request should be in JSON format.");
            var result = caller->respond(response);

        }

    }
}
