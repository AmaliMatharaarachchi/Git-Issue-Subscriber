
//functions for subscribe
public function setSubscriber(string repositoryOwner, string repositoryName, string subscriber_email) returns boolean {
    var repository = getRepository(repositoryOwner, repositoryName);
    if (repository is map<string>) {
        boolean added = addSubscriber(repositoryOwner, repositoryName, subscriber_email);
        if (added) {
            sendWelcomeMail(repositoryOwner, repositoryName, subscriber_email, untaint repository);
            return true;
        }
    }

    return false;
}

public function sendWelcomeMail(string repositoryOwner, string repositoryName, string subscriber_email, map<string> repo
                    ) {
    string repo_name = repositoryOwner + "/" + repositoryName;
    string body = "You are now subscribed to GitHub repository " + repo_name + "! \n" + "This repository has " +
        repo.forks + " forks. " + repo.stars + " stars. Go to " + repo.url + " for more details";
    string subject = "Subscribed to GitHub Repository " + repo_name;
    sendMail(subscriber_email, subject, body);
}

//functions for post issue
public function setIssue(string repositoryOwner, string repositoryName, string issueTitle,
                         string issueContent) returns boolean {
    boolean posted = postIssuetoRepository(repositoryOwner, repositoryName, issueTitle, issueContent, [],
        []);
    if (posted) {
        notifySubscribers(repositoryOwner, repositoryName);
        return true;
    }
    return false;
}

public function notifySubscribers(string repositoryOwner, string repositoryName) {
    string[] subscribers = getSubscribers(repositoryOwner, repositoryName);
    foreach string email in subscribers {
        sendNewIssueMail(repositoryOwner, repositoryName, untaint email);
    }
}

public function sendNewIssueMail(string repositoryOwner, string repositoryName, string subscriber_email) {
    string repo_name = repositoryOwner + "/" + repositoryName;
    string body = "New issue has been posted to GitHub repository " + repo_name + "! \n Go to " + "https://github.com/"
        + repo_name + " for more details";
    string subject = "A new issue posted to GitHub Repository " + repo_name;
    sendMail(subscriber_email, subject, body);
}
