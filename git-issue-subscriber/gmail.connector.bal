import ballerina/io;
import ballerina/log;
import wso2/gmail;

//create gmail REST API client
gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

gmail:Client gmailClient = new(gmailConfig);

# send mail
# + recipient - Recipient name
# + subject - Email subject
# + body - Email body
# + return - Boolean value, email sent
public function sendMail(string recipient, string subject, string body) returns json {
    string userId = "me";
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = recipient;
    messageRequest.sender = config:getAsString("EMAIL");
    messageRequest.subject = subject;
    messageRequest.messageBody = body;
    messageRequest.contentType = gmail:TEXT_PLAIN;
    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    json ret = { "status": 502 };

    if (sendMessageResponse is (string, string)) {
        log:printInfo("Email sent to : " + recipient);
        ret.status = 200;
        return ret;
    }
    else {
        log:printError("Error while sending email to " + recipient + ". " + <string>sendMessageResponse.detail().message
        );
        ret["err"] = "Error while sending email to " + recipient + ". " + <string>sendMessageResponse.detail().message;
        return ret;
    }

}