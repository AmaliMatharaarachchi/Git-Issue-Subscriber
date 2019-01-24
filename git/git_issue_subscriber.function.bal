import ballerina/log;

//functions for subscribe

# add subscriber to mysql database and send the email notification to subscriber's email
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, subscription is successful
public function setSubscriber(string repositoryOwner, string repositoryName, string subscriberEmail) returns boolean {
    var repositoryDetail = getRepository(repositoryOwner, repositoryName);

    if (repositoryDetail is map<string>) {
        boolean added = addSubscriber(repositoryOwner, repositoryName, subscriberEmail);

        if (added) {
            boolean sent = sendWelcomeMail(repositoryOwner, repositoryName, untaint repositoryDetail, subscriberEmail);
            return true;
        }
    }
    else {
        log:printError("Error retrieving while retrieving repository details");
    }
    return false;
}

# send the email notification on subscription to subscriber's email
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + repositoryDetails - Repository details, number of forks and stargazers
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, mail sent successfully
public function sendWelcomeMail(string repositoryOwner, string repositoryName, map<string> repositoryDetails, string
    subscriberEmail) returns boolean {
    string repositoryFullName = repositoryOwner + "/" + repositoryName;
    string body = "You are now subscribed to GitHub repository " + repositoryFullName + "! \n" + "This repository has "
        + repositoryDetails.forks + " forks. " + repositoryDetails.stars + " stars. Go to " + repositoryDetails.url +
        " for more details";
    string subject = "Subscribed to GitHub Repository " + repositoryFullName;
    boolean sent = sendMail(subscriberEmail, subject, body);
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
                                                                                                                boolean
{
    boolean posted = postIssuetoRepository(repositoryOwner, repositoryName, issueTitle, issueContent, [], []);

    if (posted) {
        notifySubscribers(repositoryOwner, repositoryName);
        return true;
    }
    return false;
}

# send the email notification on new issue to all subscribes of the issue
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
public function notifySubscribers(string repositoryOwner, string repositoryName) {
    string[] subscribers = getSubscribers(repositoryOwner, repositoryName);

    foreach string email in subscribers {
        boolean sent = sendNewIssueMail(repositoryOwner, repositoryName, untaint email);

        if (!sent) {
            log:printError("new issue notification mail not sent to email address : " + email);
        }
    }
}

# send the email notification on new issue
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + subscriberEmail - Subscriber's email address
# + return - Boolean value, mail sent successfully
public function sendNewIssueMail(string repositoryOwner, string repositoryName, string subscriberEmail) returns boolean
{
    string repositoryFullName = repositoryOwner + "/" + repositoryName;
    string body = "New issue has been posted to GitHub repository " + repositoryFullName + "! \n Go to " +
        "https://github.com/" + repositoryFullName + " for more details";
    string subject = "A new issue posted to GitHub Repository " + repositoryFullName;
    boolean sent = sendMail(subscriberEmail, subject, body);
    return sent;
}
