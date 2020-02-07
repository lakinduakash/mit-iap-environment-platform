import ballerina/http;
import ballerina/stringutils;

// Client APIs' section.
const string GITHUB_API_URL = "https://api.github.com";
const string ORGANIZATION_NAME = "yashodgayashan";
const string REPOSITORY_NAME = "ballerina-github-connector";
const string ACCESS_TOKEN = "Bearer <token>";

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

# The `toStringArray` function will convert a json array into string array.
# 
# + inputArray - Json array.
# + return     - Returns the converted json array as a string array.
public function toStringArray(json[] inputArray) returns string[] {

    string[] outputArray = [];
    foreach var item in inputArray {
        outputArray[outputArray.length()] = item.toString();
    }
    return outputArray;
}

# The `getNotFoundStatus` function returns the not found status and the code as a string[]
# 
# + return - Returns status and status code.
public function getNotFoundStatus() returns string[] {

    return ["404", "Not Found"];
}

# The `getStatus` function will return the status of the **http:Response**
# 
# + response - Http response.
# + return   - Returns a **string[]** which includes the status code and the message.
public function getStatus(http:Response response) returns string[] {

    string status = "";
    status = response.getHeader("Status");
    string[] statusDetails = stringutils:split(status, " ");
    status = "";
    foreach int value in 1 ..< statusDetails.length() {
        status = status + statusDetails[value] + " ";
    }
    return [statusDetails[0], status];
}

# The `createAFormattedJsonOfAnIssue` function rebuilds a formatted issue using the retrieved 
# json issue.
#
# + issue  - Issue retrieved from the github API service. 
# + return - Returns a formatted **json** of an issue, **error** if a formatted json issue 
#            cannot be rebuilt or the issue with the issue number doesn't exist.
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

# The `extractIssuesRelatedToUser` function extracts all the issues related to a specific user.
#
# + listOfIssues - All the issues related to a specific repsitory. 
# + userName     - Username of the user. 
# + return       - Returns a formatted **json[]** of issues related to the user, **error** 
#                  if a formatted json array of issues cannot be rebuilt or the length of
#                  the json array length is zero.
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
                    issues[issues.length()] = {"requsetTitle":check issue.title, "requestNumber":check issue.number, "requestDetails":check issue.body, "state": state};
                } else {
                    issues[issues.length()] = {"requsetTitle":check issue.title, "requestNumber":check issue.number, "requestDetails":check issue.body, "state": "Pending"};
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
# + listOfIssues - All the issues related to a specific repsitory. 
# + authorityName- Authority name of the authority. 
# + return       - Returns a formatted **json[]** of issues related to the authority, **error** 
#                  if a formatted json array of issues cannot be rebuilt or the length of
#                  the json array length is zero.
public function extractIssuesRelatedToAuthority(json[] listOfIssues, string authorityName) returns json | error {

    json[] | error requests = createFormattedIssues(listOfIssues);
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

# The `userNameExists` function checks if the username exists inside the labels of the issue.
#
# + labels   - Labels of the issue.
# + userName - Name of the user.
# + return   - Returns a **boolean** which indicates whether the user exists or not.
public function userNameExists(json[] labels, string userName) returns boolean {

    foreach json label in labels {
        if (userName == (label.labelName.toString())) {
            return true;
        }
    }
    return false;
}

# The `createAFormattedJsonOfCollaborators` function rebuilds a formatted json array of 
# collaborators out of the original json array of collaborators.
# 
# + collaborators - Original json array of collaborators.  
# + return        - Returns a formatted **json[]** of collaborators, **error** if a formatted 
#                   json array of collaborators cannot be rebuilt.
public function createAFormattedJsonOfCollaborators(json[] collaborators) returns json | error {

    json[] formattedCollaborators = [];
    foreach json collaborator in collaborators {
        map<json> collaboratorRecord = <map<json>>collaborator;
        formattedCollaborators[formattedCollaborators.length()] = {
            "id":check collaboratorRecord.id,
            "name":check collaboratorRecord.login,
            "url":check collaboratorRecord.url
        };
    }
    return formattedCollaborators;
}

# The `isValidCollaborator` function checks whether a user is a collaborator or not.
#
# + collaboratorName - Username of the collaborator. 
# + return           - Returns a **boolean** which indicates whether the collaborator exists or not
#                      , returns an **error** if the github response is not in the expected form.
public function isValidCollaborator(string collaboratorName) returns boolean | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators/" + collaboratorName;

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        return githubResponse.statusCode == 204 ? true : false;
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}

# The `createAFormattedJsonOfAssignees` function rebuilds a formatted json array of 
# assignees out of the original json array of assignees.
#
# + assignees - Original json array of assignees.  
# + return    - Returns a formatted **json[]** of assignees, **error** if a formatted 
#               json array of assignees cannot be rebuilt.
public function createAFormattedJsonOfAssignees(json[] assignees) returns json | error {

    json[] assigneeDetails = [];
    foreach json assignee in assignees {
        map<json> assigneeRecord = <map<json>>assignee;
        assigneeDetails[assigneeDetails.length()] = {
            "id":check assigneeRecord.id,
            "userName":check assigneeRecord.login,
            "url":check assigneeRecord.url
        };
    }
    return assigneeDetails;
}

# The `areValidAssignees` function checks if the assignees already exists.
#
# + userNames - Usernames corresponding to the assignees. 
# + return    - Returns a **boolean** which indicates whether all the assignees exists or not
#               , returns an **error** if the github response is not in the expected form.
public function areValidAssignees(json[] userNames) returns boolean | error {

    foreach json userName in userNames {
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/assignees/" + userName.toString();

        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

        if (githubResponse is http:Response) {
            if (githubResponse.statusCode != 204) {
                return false;
            }
        } else {
            return error("The github response is not in the expected form: http:Response.");
        }
    }

    return true;
}

# The `isValidIssue` function checks whether an issue with the provided issue number exists.
#
# + issueNumber - Issue number related to the issue. 
# + return      - Returns a **boolean** which indicates whether the issue exists or not, 
#                 returns an **error** if the github response is not in the expected form.
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

# The `isValidComment` function checks whether a comment with the provided comment id exists.
#
# + commentId - Comment Id related to the comment. 
# + return    - Returns a **boolean** which indicates whether the comment exists or not, 
#               returns an **error** if the github response is not in the expected form.
public function isValidComment(string commentId) returns boolean | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;

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
# + userName - Name of the user.
# + issueNumber - Number of the issue.
# + return - Return a **boolean** indicating whther the issue is related to the user or the
#           **error** occur.
public function isValidUserOnIssue(string userName, string issueNumber) returns boolean | error {

    json[] | error labels = getLabelsOnIssue(issueNumber);

    if (labels is json[]) {
        json | error formattedLabels = createAFormattedJsonOfLabels(labels);
        if (formattedLabels is json) {
            json[] labelArray = <json[]>formattedLabels;
            return userNameExists(labelArray, userName);
        } else {
            return error("Json format of the label list is not valid");
        }
    } else {
        return labels;
    }
}

# The `createAFormattedJsonOfComments` function rebuilds a formatted json array of 
# comments out of the original json array of comments.
#
# + comments - Original json array of comments.  
# + return    - Returns a formatted **json[]** of comments, **error** if a formatted 
#               json array of comments cannot be rebuilt.
public function createAFormattedJsonOfComments(json[] comments) returns json | error {

    json[] commentDetails = [];
    foreach json comment in comments {
        map<json> commentRecord = <map<json>>comment;
        map<json> user = <map<json>>commentRecord.user;
        commentDetails[commentDetails.length()] = {
            "id":check commentRecord.id,
            "body":check commentRecord.body,
            "user":check user.login
        };
    }
    return commentDetails;
}

# The `isValidCommentOfUser` function checks whether a comment with the provided comment id is created by the 
# given user.
#
# + commentId - Comment Id related to the comment. 
# + userName - Name of the user.
# + return    - Returns a **boolean** which indicates whether the comment is created by the given user or
#               returns an **error** if the github response is not in the expected form.
public function isValidCommentOfUser(string commentId, string userName) returns boolean | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        if (githubResponse.statusCode == 200) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json) {
                map<json> user = <map<json>>jsonPayload;
                return user.login == userName ? true : false;
            } else {
                return error("The payload is not in json format");
            }
        } else {
            return error("The comment id is not valid");
        }
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}


public function createFormattedIssues(json[] issues) returns json[] | error {

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
                labelArray[labelArray.length()] = {"name":check label.name, "body":check label.description};
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

public function createFormattedComments(json[] comments) returns json[] | error {

    json[] formattedComments = [];
    foreach json comment in comments {
        map<json> user = <map<json>>comment.user;
        formattedComments[formattedComments.length()] = {
            "commentId":check comment.id,
            "user":check user.login,
            "comment":check comment.body
        };
    }
    return formattedComments;
}

public function createFormattedUser(json user) returns json | error {

    map<json> userVal = <map<json>>user;
    json userDetails = {"userName":check userVal.login};

    return userDetails;
}
