import ballerina/config;
import ballerina/http;
import ballerina/io;
import wso2/github4;

//create mySQL REST API client
github4:GitHubConfiguration gitHubConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("GITHUB_TOKEN")
        }
    }
};

github4:Client githubClient = new(gitHubConfig);

# get repository details
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + return - Map<string> of repository details or error
public function getRepository(string repositoryOwner, string repositoryName) returns json {
    string repositoryFullName = repositoryOwner + "/" + repositoryName;
    var result = githubClient->getRepository(repositoryFullName);
    json ret = {};
    if (result is github4:Repository) {
        string forkCount = string.convert(result.forkCount ?: 0);
        string stargazerCount = string.convert(result.stargazerCount ?: 0);
        string url = result.url ?: "";
        string owner = result.owner.url;
        string avatarUrl = result.owner.avatarUrl ?: "";
        json details = { "forks": forkCount, "stars": stargazerCount, "url": url, "owner": owner, "owneravatar":
        avatarUrl };
        log:printInfo("for repository : " + repositoryFullName + " details received. ");
        ret["details"] = details;
        ret["status"] = 200;
    } else {
        log:printError("repository not found");
        ret["err"] = "Repository with name: " + repositoryFullName + " is not found";
        ret["status"] = 502;
    }
    return ret;
}

# post issue to repository
# + repositoryOwner - Repository owner name
# + repositoryName - Repository name
# + issueTitle - Title of issue
# + issueContent - Content of issue
# + labelList - List of labels
# + assigneeList - List of assignees
# + return - Boolean value, issue posted successfully
public function postIssuetoRepository(string repositoryOwner, string repositoryName, string issueTitle,
                                      string issueContent, string[] labelList, string[] assigneeList) returns json {
    var result = githubClient->createIssue(repositoryOwner, repositoryName, issueTitle, issueContent, labelList,
        assigneeList);
    json ret = {};

    if (result is github4:Issue) {
        log:printInfo("New issue is posted to repository :" + repositoryOwner + "/" + repositoryName);
        ret["status"] = 200;
    }
    else {
        log:printError("error in posting issue ");
        ret["status"] = 502;
        ret["err"] = "error in posting issue";
    }
    return ret;
}

