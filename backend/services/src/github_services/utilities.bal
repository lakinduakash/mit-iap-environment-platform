import ballerina/http;
import ballerina/io;
import ballerina/lang.'int as ints;
import ballerina/stringutils;

# The `assignLabel` function will assign the labels to a given issue.
#
# + issueNumber - Issue number which the given labels should be assigned to.
# + labels      - Array of labels which should be assigned to the issue.
# + return      - Returns a **string[]** which includes the status code and the message.
public function assignLabel(string issueNumber, string[] labels) returns string[] {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({"labels": labels});
    http:Response | error response = githubAPIEndpoint->post(url, request);

    if (response is http:Response) {
        io:println(response.getJsonPayload());
        return getStatus(response);
    } else {
        io:println(response.reason());
        return getNotFoundStatus();
    }
}

# The `checkLabel` function is used to check whether the given label is available or not.
# 
# + labelName - Name of the label.
# + return    - Returns a **string[]** which indicates the status.
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


public function checkLabels(string labelName) returns @untainted string[] {
    return [];
}

# The `toStringArray` function will convert a json array into string array.
# 
# + inputArray - Json array.
# + return - Returns the converted json array as a string array.
public function toStringArray(json[] inputArray) returns string[] {

    string[] outputArray = [];
    foreach var item in inputArray {
        outputArray[outputArray.length()] = item.toString();
    }
    return outputArray;
}

# The `createLabel` function will create a label in a specified git repository.
# 
# + labelName        - Name of the label.
# + labelDescription - Description of the label.
# + return           - Returns a **json** which indicates the status.
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

# The `createLabelIfNotExists` function creates a label if the relevant label is not yet available.
# 
# + labelName        - Name of the label.
# + labelDescription - Description of the label.
# + return           - Returns a **string[]** which indicates the status.
public function createLabelIfNotExists(string labelName, string labelDescription) returns string[] {

    string[] status = checkLabel(labelName);
    int | error statusCode = ints:fromString(status[0]);

    if (statusCode is int && statusCode == http:STATUS_OK) {
        return [status[0], "Already exists."];
    } else {
        return createLabel(labelName, labelDescription);
    }
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

# Rebuild a formatted issue using the retrieved issue from github API services.
#
# + issue  - Issue retrieved from github API services. 
# + return - Formatted issue in json format, error if the issue cannot be rebuilt.
public function createFormattedIssue(json issue) returns json | error {

    json formattedIssue = {};
    json[] | error labels = trap <json[]>issue.labels;

    if (labels is json[]) {
        json | error labelDetails = createFormattedLabels(labels);
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

# Extract all the issues related to a specific user.
#
# + listOfIssues - All the issues related to a specific repsitory. 
# + userName     - Name of the user. 
# + return       - Issues related to a specific user in the form of json, error if issues cannot be extracted.
public function extractIssuesRelatedToUser(json[] listOfIssues, string userName) returns json | error {

    json[] issues = [];
    foreach json issue in listOfIssues {
        map<json> issueVal = <map<json>>issue;
        json labelDetails = check createFormattedLabels(<json[]>issueVal.labels);

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

    if (issues.length() > 0) {
        return issues;
    } else {
        return error("Issues for the specified user cannot be found.");
    }

}

# Check if the userName exists inside the labels.
#
# + labels   - Labels of an issue.
# + userName - Name of the user.
# + return   - True if the user exists, false if else.
function userNameExists(json[] labels, string userName) returns boolean {

    foreach json label in labels {
        if (userName == (label.labelName.toString())) {
            return true;
        }
    }
    return false;
}

# Rebuild a formatted set of labels using the retrieved issue from github API services.
#
# + labels - Labels retrieved from github API services in the form of issue.  
# + return - Formatted set of lables in json format, error if the set of labels cannot be rebuilt.
function createFormattedLabels(json[] labels) returns json | error {

    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelVal = <map<json>>label;
        labelDetails[labelDetails.length()] = {"labelName":check labelVal.name, "labelDescription":check labelVal.description};
    }
    return labelDetails;
}

# Rebuild a formatted set of collaborators using the retrieved issue from github API services.
#
# + collaborators - Collaborators retrieved from github API services.  
# + return        - Formatted set of collaborators in json format, error if the set of collaborators cannot be rebuilt.
function createFormattedCollaborators(json[] collaborators) returns json | error {

    json[] formattedCollaborators = [];
    foreach json collaborator in collaborators {
        map<json> collaboratorValue = <map<json>>collaborator;
        formattedCollaborators[formattedCollaborators.length()] = {"id":check collaboratorValue.id, "name":check collaboratorValue.login, "url":check collaboratorValue.url};
    }
    return formattedCollaborators;
}

public function getAllLabels() returns json | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error response = githubAPIEndpoint->get(url, request);

    if (response is http:Response) {
        var jsonPayload = response.getJsonPayload();
        if (jsonPayload is json) {
            return <@untainted>jsonPayload;
        } else {
            return error("Error of the jsonPayload.");
        }
    } else {
        return error("Error while retreving labels from the github.");
    }
}

public function getLabelNames(json | error labels) returns string[] | error {

    string[] labelNames = [];
    json[] | error labelArray = trap <json[]>labels;
    if (labelArray is json[]) {
        foreach json item in labelArray {
            map<json> | error labelInfo = trap <map<json>>item;
            if (labelInfo is map<json>) {
                string labelName = labelInfo.name.toString();
                labelNames[labelNames.length()] = labelName;
            } else {
                return labelInfo;
            }
        }
        return labelNames;
    } else {
        return labelArray;
    }
}
