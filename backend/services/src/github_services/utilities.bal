import ballerina/http;
import ballerina/lang.'int as ints;
import ballerina/stringutils;

# The `assignLabel` function will assign the labels to the given issue.
# 
# + issueNumber - The issue number which all the given labels are assigned.
# + labels - Array of labels which should assign to the issue.
# 
# + return - The function will return the **string[]** which includes the status code and the message.
public function assignLabel(string issueNumber, string[] labels) returns string[] {

    string url = "repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({"labels": labels});
    http:Response | error response = githubAPIEndpoint->post(url, request);

    if (response is http:Response) {
        return getStatus(response);
    } else {
        return getNotFoundStatus();
    }
}

# The `checkLabel` function use to check whether the given label is available or not.
# 
# + labelName - The checking label name.
# 
# + return - The `checkLabel` function will return **string[]** to indicate the status.
public function checkLabel(string labelName) returns @untainted string[] {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels/" + labelName;

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error response = githubAPIEndpoint->get(url, request);

    if (response is http:Response) {
        return getStatus(response);
    } else {
        return getNotFoundStatus();
    }
}

# The `createLabel` Function will create a label in github in particular repositary.
# 
# + labelName - The creating label name.
# + labelDescription - The description of the label
# 
# + return - The `createLabel` function will return **json** to indicate the status.
public function createLabel(string labelName, string labelDescription) returns string[] {

    json requestPayLoad = {
        "name": labelName,
        "description": labelDescription,
        "color": "f29513"
    };
    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload(requestPayLoad);

    http:Response | error response = githubAPIEndpoint->post(url, request);
    if (response is http:Response) {
        return getStatus(response);
    } else {
        return getNotFoundStatus();
    }
}

# The `createLabelIfNotExists` function creates a label if the relevant label is not available.
#
# + labelName - The creating label name.
# + labelDescription - The description of the label
#
# + return - The `createLabelIfNotExists` function will return **string[]** to indicate the status.
public function createLabelIfNotExists(string labelName, string labelDescription) returns string[] {

    string[] status = checkLabel(labelName);
    int | error statusCode = ints:fromString(status[0]);

    if (statusCode is int && statusCode == http:STATUS_OK) {
        return [status[0], "Already exists."];
    } else {
        return createLabel(labelName, labelDescription);
    }
}

# The `getNotFoundStatus` function returns the not found status and the code as a json
# 
# + return -  Returns not found status and status code.
public function getNotFoundStatus() returns string[] {

    return ["404", "Not Found"];
}

# The `getStatus` function will return the status of the **http:Response**
# 
# + response - Inputting reponse
# 
# + return - The function will return the string array which includes the status code and the message.
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

public function createFormattedIssue(json issue) returns json | error {

    json labelDetails = check getLabels(<json[]>issue.labels);
    json formattedIssue = {
        "issueId":check issue.id,
        "issueNumber":check issue.number,
        "labels": labelDetails,
        "issueTitle":check issue.title,
        "issueBody":check issue.body
    };
    return formattedIssue;
}

public function extractIssuesRelatedToUser(json[] listOfIssues, string userName) returns json | error {

    json[] issues = [];
    foreach json issue in listOfIssues {
        map<json> issueVal = <map<json>>issue;
        json labelDetails = check getLabels(<json[]>issueVal.labels);

        if (userNameExists(<json[]>labelDetails, userName)) {
            json issueInfo = {
                "issueId":check issueVal.id,
                "issueNumber":check issueVal.number,
                "labels": labelDetails,
                "issueTitle":check issueVal.title,
                "issueBody":check issueVal.body
            };
            issues[issues.length()] = issueInfo;
        }
    }
    return issues;
}

function userNameExists(json[] labels, string userName) returns boolean {

    foreach json label in labels {
        if (userName == (label.labelName.toString())) {
            return true;
        }
    }
    return false;
}

function getLabels(json[] labels) returns json | error {

    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelVal = <map<json>>label;
        labelDetails[labelDetails.length()] = {"labelName":check labelVal.name, "labelDescription":check labelVal.description};
    }
    return labelDetails;
}
