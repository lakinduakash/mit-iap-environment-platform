import ballerina/http;
import ballerina/stringutils;

# The `checkLabel` function use to check whether the given label is available or not.
# 
# + labelName - The checking label name.
# + repoUser - The name of the repositary owner.
# + repoName - The name of the repositary.
# 
# + return - The `checkLabel` function will return **boolean** to indicate whether the label is available.
function checkLabel(string labelName, string repoUser, string repoName) returns @untainted boolean {
    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    var response = githubAPIEndpoint->get("/repos/" + repoUser + "/" + repoName + "/labels/" + labelName);
    string status = "";
    if response is http:Response {
        status = response.getHeader("Status");
        string[] statusDetails = stringutils:split(status, " ");
        if statusDetails[0] == "200" {
            return true;
        } else {
            return false;
        }
    }
    return false;
}
