import ballerina/log;

//functions for subscribe

# add subscriber to mysql database and send the email notification to subscriber's email
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, subscription is successful
public function setSubscriber(string repositoryOwner, string repositoryName, string subscriberEmail) returns json {
    json result = getRepository(repositoryOwner, repositoryName);
    json ret = {};

    if (result.status == 200) {
        json added = addSubscriber(repositoryOwner, repositoryName, subscriberEmail);
        var repositoryDetails = untaint map<string>.convert(result.details);

        if (repositoryDetails is map<string>) {
            if (added.status == 200) {
                json sent = sendWelcomeMail(repositoryOwner, repositoryName, repositoryDetails, subscriberEmail);
                ret["status"] = 200;
            }
            else {
                return added;
            }
        }
    }
    else {
        log:printError("Error retrieving while retrieving repository details");
        return result;
    }
    return ret;
}

# send the email notification on subscription to subscriber's email
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + repositoryDetails - Repository details, number of forks and stargazers
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, mail sent successfully
public function sendWelcomeMail(string repositoryOwner, string repositoryName, map<string> repositoryDetails, string
    subscriberEmail) returns json {
    string repositoryFullName = repositoryOwner + "/" + repositoryName;
    string body = "You are now subscribed to GitHub repository " + repositoryFullName + "! \n" + "This repository has "
        + repositoryDetails.forks + " forks. " + repositoryDetails.stars + " stars. Go to " + repositoryDetails.url +
        " for more details";
    string subject = "Subscribed to GitHub Repository " + repositoryFullName;
    json sent = sendMail(subscriberEmail, subject, body);
    return sent;
}

//functions for post issue

# post issue in github repository and send email notification to all subscribers of the issue
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + issueTitle - Title of the issue
# + issueContent - Content of the issue
# + return - Boolean value, issue posted successfully
public function setIssue(string repositoryOwner, string repositoryName, string issueTitle, string issueContent) returns
                                                                                                                json
{
    json postIssueResult = postIssuetoRepository(repositoryOwner, repositoryName, issueTitle, issueContent, [], []);

    if (postIssueResult.status == 200) {
        notifySubscribers(repositoryOwner, repositoryName);
    }
    return postIssueResult;
}

# send the email notification on new issue to all subscribes of the issue
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
public function notifySubscribers(string repositoryOwner, string repositoryName) {
    json subscribersResult = getSubscribers(repositoryOwner, repositoryName);

    if (subscribersResult.status == 200) {
        string[] subscribers = <string[]>subscribersResult.subscribers;

        foreach string email in subscribers {
            json sentMailResult = sendNewIssueMail(repositoryOwner, repositoryName, untaint email);

            if (sentMailResult.status != 200) {
                log:printError("new issue notification mail not sent to email address : " + email);
            }
        }
    }

}

# send the email notification on new issue
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, mail sent successfully
public function sendNewIssueMail(string repositoryOwner, string repositoryName, string subscriberEmail) returns json
{
    string repositoryFullName = repositoryOwner + "/" + repositoryName;
    string body = "New issue has been posted to GitHub repository " + repositoryFullName + "! \n Go to " +
        "https://github.com/" + repositoryFullName + " for more details";
    string subject = "A new issue posted to GitHub Repository " + repositoryFullName;
    json sentMailResult = sendMail(subscriberEmail, subject, body);
    return sentMailResult;
}
