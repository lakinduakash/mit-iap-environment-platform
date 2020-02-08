import ballerina/http;
import ballerina/lang.'int as ints;

# The `getAllLabels` function retrieves all the labels of the repository using the github 
# API services.
#
# + return - Returns a **json** consisting all the labels, **error** if the labels cannot 
# be extracted properly.
public function getAllLabels() returns json | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        var jsonPayload = githubResponse.getJsonPayload();
        if (jsonPayload is json) {
            return <@untainted>jsonPayload;
        } else {
            return error("Error while extracting the jsonPayload from the github response.");
        }
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}

# The `getLabelsIsOnIssue` function retrieves all the labels for a given issue.
# 
# + issueNumber - Issue number related to the issue.
# + return      - Returns a **json[]** which includes all the labels for the given issue or 
# an **error** occurred during processing.
public function getLabelsOnIssue(string issueNumber) returns json[] | error {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        var jsonPayload = githubResponse.getJsonPayload();
        if (jsonPayload is json) {
            json[] | error labelArray = trap <json[]>jsonPayload;
            if (labelArray is json[]) {
                return <@untainted>labelArray;
            } else {
                return error("The github jsonPayload is not in the expected form: json[]");
            }
        } else {
            return error("Error while extracting the jsonPayload from the github response.");
        }
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}

# The `createLabelIfNotExists` function creates a label if the relevant label is not yet available.
# 
# + labelName        - Name of the label.
# + labelDescription - Description of the label.
# + return           - Returns a **string[]** which indicates the status of label creation.
public function createLabelIfNotExists(string labelName, string labelDescription) returns string[] {

    string[] status = checkLabel(labelName);
    int | error statusCode = ints:fromString(status[0]);

    if (statusCode is int && statusCode == http:STATUS_OK) {
        return [status[0], "Already exists."];
    } else {
        return createLabel(labelName, labelDescription);
    }
}

# The `createLabel` function will create a label in a specified github repository.
# 
# + labelName        - Name of the label.
# + labelDescription - Description of the label.
# + return           - Returns a **json** which indicates the status of label creation.
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

    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        return getStatus(githubResponse);
    } else {
        return getNotFoundStatus();
    }
}

# The `checkLabel` function is used to check whether the given label is available or not.
# 
# + labelName - Name of the label.
# + return    - Returns a **string[]** which indicates the availability of the label using
# status code and message.
public function checkLabel(string labelName) returns @untainted string[] {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels/" + labelName;

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    if (githubResponse is http:Response) {
        return getStatus(githubResponse);
    } else {
        return getNotFoundStatus();
    }
}

# The `assignLabel` function will assign the provided labels to a given issue.
#
# + issueNumber - Issue number which the given labels should be assigned to.
# + labels      - Array of labels which should be assigned to the issue.
# + return      - Returns a **string[]** which includes the status code and the message.
public function assignLabel(string issueNumber, string[] labels) returns string[] {

    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({"labels": labels});
    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);

    if (githubResponse is http:Response) {
        return getStatus(githubResponse);
    } else {
        return getNotFoundStatus();
    }
}

# The `removeLabel` function removes a label from a specific issue.
#
# + issueNumber - Issue number which the given label should be removed. 
# + labelName   - Name of the label to be removed from the issue. 
# + return      - Returns a **int** which represents the status of the removal.
public function removeLabel(string issueNumber, string labelName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels/" + labelName;
    http:Response | error githubResponse = githubAPIEndpoint->delete(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

# The `createAFormattedJsonOfLabels` function rebuilds a formatted json array of labels out 
# of the original json array of labels.
# 
# + labels - Original json array of labels.  
# + return - Returns a formatted **json[]** of labels, **error** if a formatted json array 
# of labels cannot be rebuilt.
public function createAFormattedJsonOfLabels(json[] labels) returns json | error {

    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelRecord = <map<json>>label;
        labelDetails[labelDetails.length()] = {
            "labelName":check labelRecord.name,
            "labelDescription":check labelRecord.description
        };
    }
    return labelDetails;
}

# The `createAFormattedJsonOfStateLabels` function rebuilds a formatted json array of state 
# labels out of the original json array of labels.
# 
# + labels - Original json array of labels.  
# + return - Returns a formatted **json[]** of state labels, **error** if a formatted json 
# array of labels cannot be rebuilt.
public function createAFormattedJsonOfStateLabels(json[] labels) returns json | error {

    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelRecord = <map<json>>label;
        json description = check labelRecord.description;
        if (description == "state") {
            labelDetails[labelDetails.length()] = {
                "labelName":check labelRecord.name,
                "labelDescription":check labelRecord.description
            };
        }
    }
    return labelDetails;
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
