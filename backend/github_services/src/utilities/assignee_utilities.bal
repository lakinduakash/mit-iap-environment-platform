import ballerina/http;

# The `createAFormattedJsonOfAssignees` function rebuilds a formatted json array of 
# assignees out of the original json array of assignees.
#
# + assignees - Original json array of assignees.  
# + return    - Returns a formatted **json[]** of assignees, **error** if a formatted 
# json array of assignees cannot be rebuilt.
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
# , returns an **error** if the github response is not in the expected form.
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
