import ballerina/http;

//todo -> errors. response status. handle untaint. error handle these values exist in subscribed_request
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
        var subscribe_request = request.getJsonPayload();
        http:Response response = new;

        if (subscribe_request is json) {
            string repositoryOwner = untaint <string>subscribe_request.repositoryOwner;
            string repositoryName = untaint <string>subscribe_request.repositoryName;
            string email = untaint <string>subscribe_request.email;
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
        var issue_request = request.getJsonPayload();
        http:Response response = new;

        if (issue_request is json) {
            string repositoryOwner = untaint <string>issue_request.repositoryOwner;
            string repositoryName = untaint <string>issue_request.repositoryName;
            string issueTitle = untaint <string>issue_request.issueTitle;
            string issueContent = untaint <string>issue_request.issueContent;
            boolean posted = setIssue(repositoryOwner, repositoryName, issueTitle, issueContent);

            if (posted) {
                response.setTextPayload("successful! posted issue to "+repositoryName);
            }
            else {
                response.setTextPayload("Error! failed to post issue to "+repositoryName);
            }
        }
        else {
            response.setTextPayload("Error! issue post request should be in JSON format.");
        }
        var result = caller->respond(response);
    }
}
