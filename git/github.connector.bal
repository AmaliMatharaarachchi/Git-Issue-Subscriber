import ballerina/config;
import ballerina/http;
import ballerina/io;
import wso2/github4;

github4:GitHubConfiguration gitHubConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("GITHUB_TOKEN")
        }
    }
};

github4:Client githubClient = new(gitHubConfig);

public function getRepository(string repositoryOwner, string repositoryName) returns map<string>|error {
    string repo_name = repositoryOwner + "/" + repositoryName;
    var result = githubClient->getRepository(repo_name);
    if (result is github4:Repository) {
        string forkCount = string.convert(result.forkCount ?: 0);
        string stargazerCount = string.convert(result.stargazerCount ?: 0);
        string url = result.url ?: "";
        string owner = result.owner.url;
        string avatarUrl = result.owner.avatarUrl ?: "";

        map<string> details = { forks: forkCount, stars: stargazerCount, url: url, owner: owner, owneravatar: avatarUrl
        };
        return details;
    } else {
        RepositoryNotFoundError repositoryNotFoundError = error("Repository with name: "
            + repo_name + " is not found", { repo_name: <string>repo_name });
        return repositoryNotFoundError;
    }
}

public function postIssuetoRepository(string repositoryOwner, string repositoryName, string issueTitle,
                                      string issueContent, string[] labelList, string[] assigneeList) returns boolean {
    var result = githubClient->createIssue(repositoryOwner, repositoryName, issueTitle, issueContent, labelList,
        assigneeList);
    if (result is github4:Issue) {
        return true;
    }
    else {
        io:println("error in posting issue : ", result);
    }
    return false;
}

