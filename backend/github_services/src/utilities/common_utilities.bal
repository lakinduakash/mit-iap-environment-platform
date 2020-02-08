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
