import ballerina/http;

# The `createAFormattedJsonOfAnIssue` function rebuilds a formatted issue using 
# the retrieved json issue.
#
# + issue  - Issue retrieved from the github API service. 
# + return - Returns a formatted **json** of an issue, **error** if a formatted 
# json issue cannot be rebuilt or the issue with the issue number doesn't exist.
public function createAFormattedJsonOfAnIssue(json issue) returns json | error {

    json formattedIssue = {};
    json[] | error labels = trap <json[]>issue.labels;

    if (labels is json[]) {
        json | error labelDetails = createAFormattedJsonOfLabels(labels);
        if (labelDetails is json) {
            formattedIssue = {
                "issueId":check issue.id,
                "issueNumber":check issue.number,
                "labels": labelDetails,
                "issueTitle":check issue.title,
                "issueBody":check issue.body
            };
        } else {
            return error("Error while creating a formatted set of labels using the extracted issue labels.");
        }
    } else {
        return error("Issue with the given issue number cannot be found.");
    }

    return formattedIssue;
}

# The `createAFormattedJsonOfIssues` function creates a formatted set of issues.
#
# + issues - All the issues related to a specific repsitory. 
# + return - Returns a formatted **json[]** of issues **error** if a formatted json 
# array of issues cannot be rebuilt.
public function createAFormattedJsonOfIssues(json[] issues) returns json[] | error {

    json[] formattedIssues = [];
    string userName = "";
    string status = "";
    json[] labelArray = [];
    string[] assigneeArray = [];

    foreach json issue in issues {
        json[] labels = <json[]>issue.labels;
        foreach json label in labels {
            if (label.description == "userName") {
                userName = <string>label.name;
            } else if (label.description == "state") {
                status = <string>label.name;
            } else {
                labelArray[labelArray.length()] = {
                    "name":check label.name, 
                    "body":check label.description
                };
            }
        }
        json[] assignees = <json[]>issue.assignees;
        foreach json assignee in assignees {
            assigneeArray[assigneeArray.length()] = <string>assignee.login;
        }
        json request = {
            "requsetNumber":check issue.number,
            "requestTitle":check issue.title,
            "requestBody":check issue.body,
            "owner": userName,
            "status": status,
            "tags": labelArray,
            "assignees": assigneeArray
        };
        userName = "";
        status = "";
        labelArray = [];
        assigneeArray = [];
        formattedIssues[formattedIssues.length()] = request;
    }

    return formattedIssues;
}

# The `extractIssuesRelatedToUser` function extracts all the issues related to a 
# specific user.
#
# + listOfIssues - All the issues related to a specific repsitory. 
# + userName     - Username of the user. 
# + return       - Returns a formatted **json[]** of issues related to the user, 
# **error** if a formatted json array of issues cannot be rebuilt or the length of
# the json array length is zero.
public function extractIssuesRelatedToUser(json[] listOfIssues, string userName) returns json | error {

    json[] issues = [];
    string state = "";
    boolean hasState = false;

    foreach json issue in listOfIssues {
        json[] labels = <json[]>issue.labels;
        foreach json label in labels {
            if (label.name == userName && label.description == "userName") {
                hasState = false;
                foreach json labelName in labels {
                    if (labelName.description == "state") {
                        state = <string>labelName.name;
                        hasState = true;
                    }
                }
                if (hasState) {
                    issues[issues.length()] = {
                        "requsetTitle":check issue.title, 
                        "requestNumber":check issue.number, 
                        "requestDetails":check issue.body, 
                        "state": state
                    };
                } else {
                    issues[issues.length()] = {
                        "requsetTitle":check issue.title, 
                        "requestNumber":check issue.number, 
                        "requestDetails":check issue.body, 
                        "state": "Pending"
                    };
                }
            }
        }
    }

    if (issues.length() > 0) {
        return issues;
    } else {
        return error("Issues for the specified user cannot be found.");
    }

}

# The `extractIssuesRelatedToAuthority` function extracts all the issues related to a specific authority.
#
# + listOfIssues  - All the issues related to a specific repsitory. 
# + authorityName - Authority name of the authority. 
# + return        - Returns a formatted **json[]** of issues related to the authority, 
# **error** if a formatted json array of issues cannot be rebuilt or the length of
# the json array length is zero.
public function extractIssuesRelatedToAuthority(json[] listOfIssues, string authorityName) returns json | error {

    json[] | error requests = createAFormattedJsonOfIssues(listOfIssues);
    json[] requestList = [];
    if (requests is json[]) {
        foreach json request in requests {
            string[] assignees = <string[]>request.assignees;
            foreach string assignee in assignees {
                if (assignee == authorityName) {
                    requestList[requestList.length()] = request;
                }
            }
        }
        if (requestList.length() > 0) {
            return requestList;
        } else {
            return error("Request for the specified authority cannot be found.");
        }
    } else {
        return error("The Issue raise when formatting the request.");
    }
}

# The `isValidIssue` function checks whether an issue with the provided issue number exists.
#
# + issueNumber - Issue number related to the issue. 
# + return      - Returns a **boolean** which indicates whether the issue exists 
# or not, returns an **error** if the github response is not in the expected form.
public function isValidIssue(string issueNumber) returns boolean | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        return githubResponse.statusCode == 200 ? true : false;
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}

# The `isValidUserOnIssue` function checks whether the issue is related to the given user.
# 
# + userName    - Name of the user.
# + issueNumber - Number of the issue.
# + return      - Return a **boolean** indicating whether the issue is related to the user 
# or the **error** occurred.
public function isValidUserOnIssue(string userName, string issueNumber) returns boolean | error {

    json[] | error labels = getLabelsOnIssue(issueNumber);

    if (labels is json[]) {
        json | error formattedLabels = createAFormattedJsonOfLabels(labels);
        if (formattedLabels is json) {
            json[] labelArray = <json[]>formattedLabels;
            return userNameExists(labelArray, userName);
        } else {
            return error("A formatted set of labels could not be extracted.");
        }
    } else {
        return labels;
    }
}
