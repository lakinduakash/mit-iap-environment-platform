import ballerina/http;

# The `createAFormattedJsonOfCollaborators` function rebuilds a formatted json array of 
# collaborators out of the original json array of collaborators.
# 
# + collaborators - Original json array of collaborators.  
# + return        - Returns a formatted **json[]** of collaborators, **error** if a formatted 
# json array of collaborators cannot be rebuilt.
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
# , returns an **error** if the github response is not in the expected form.
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
