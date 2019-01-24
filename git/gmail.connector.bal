import ballerina/io;
import wso2/gmail;

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

public function sendMail(string recipient, string subject,string body) {
    string userId = "me";
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = recipient;
    messageRequest.sender = "maamalilakshika@gmail.com";
    messageRequest.subject = subject;
    messageRequest.messageBody = body;
    //Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
    messageRequest.contentType = gmail:TEXT_PLAIN;
    //Send the message.
    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);


    if (sendMessageResponse is (string, string)) {

    } else {
        //Unsuccessful attempts return a Gmail error.
        io:println(sendMessageResponse);
    }

}