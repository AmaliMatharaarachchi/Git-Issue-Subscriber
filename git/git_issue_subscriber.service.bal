import ballerina/http;

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
        http:Response response = new;

        if (subscribeRequest is json) {
            string repositoryOwner = untaint <string>subscribeRequest.repositoryOwner;
            string repositoryName = untaint <string>subscribeRequest.repositoryName;
            string email = untaint <string>subscribeRequest.email;
            boolean subscribed = setSubscriber(repositoryOwner, repositoryName, email);

            if (subscribed) {
                response.setTextPayload("successful! subscribed to repository " + repositoryName);
            }
            else {
                response.setTextPayload("Error! failed to subscribe to" + repositoryName);
            }
        }
        else {
            response.setTextPayload("Error! subscribe request should be in JSON format.");
        }
        var result = caller->respond(response);
    }

    //endpoint to post a issue in GitHub repository-> /issue
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/issue"
    }
    resource function postIssue(http:Caller caller, http:Request request) {
        var issueRequest = request.getJsonPayload();
        http:Response response = new;

        if (issueRequest is json) {
            string repositoryOwner = untaint <string>issueRequest.repositoryOwner;
            string repositoryName = untaint <string>issueRequest.repositoryName;
            string issueTitle = untaint <string>issueRequest.issueTitle;
            string issueContent = untaint <string>issueRequest.issueContent;
            boolean posted = setIssue(repositoryOwner, repositoryName, issueTitle, issueContent);

            if (posted) {
                response.setTextPayload("successful! posted issue to " + repositoryName);
            }
            else {
                response.setTextPayload("Error! failed to post issue to " + repositoryName);
            }
        }
        else {
            response.setTextPayload("Error! issue post request should be in JSON format.");
        }
        var result = caller->respond(response);
    }
}
