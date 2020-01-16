import ballerina/http;
import ballerina/stringutils;

# The `checkLabel` function use to check whether the given label is available or not.
# 
# + labelName - The checking label name.
# + repoUser - The name of the repositary owner.
# + repoName - The name of the repositary.
# 
# + return - The `checkLabel` function will return **json** to indicate the status.
function checkLabel(string labelName, string repoUser, string repoName) returns @untainted json {
    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    var response = githubAPIEndpoint->get("/repos/" + repoUser + "/" + repoName + "/labels/" + labelName, request);
    if response is http:Response {
        return getStatus(response);
    }
    return getNotFoundStatus();
}

# The `createLabel` Function will create a label in github in particular repositary.
# 
# + repoUser - The name of the repositary owner.
# + repoName - The name of the repositary.
# + labelName - The creating label name.
# + labelDescription - The description of the label
# 
# + return - The `createLabel` function will return **json** to indicate the status.
function createLabel(string repoUser, string repoName, string labelName, string labelDescription) returns json {
    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    json requestPayLoad = {
        "name": labelName,
        "description": labelDescription,
        "color": "f29513"
    };
    request.setJsonPayload(requestPayLoad);
    var response = githubAPIEndpoint->post("/repos/" + repoUser + "/" + repoName + "/labels", request);
    if response is http:Response {
        return getStatus(response);
    } else {
        return getNotFoundStatus();
    }
}

# The `getStatus` function will return the status of the **http:Response**
# 
# + response - Inputting reponse
# 
# + return - The function will return the status code and the description as a json.
function getStatus(http:Response response) returns @untainted json {
    string status = "";
    status = response.getHeader("Status");
    string[] statusDetails = stringutils:split(status, " ");
    status = "";
    foreach int value in 1 ..< statusDetails.length() {
        status = status + statusDetails[value] + " ";
    }
    return {"statusCode": statusDetails[0], "status": status};
}

# The `getNotFoundStatus` function returns the not found status and the code as a json
# 
# + return -  Returns not found status and status code.
function getNotFoundStatus() returns json {
    return {"statusCode": "404", "status": "Not Found"};
}
