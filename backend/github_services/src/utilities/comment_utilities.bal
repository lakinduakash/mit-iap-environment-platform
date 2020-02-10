import ballerina/http;

# The `createAFormattedJsonOfComments` function rebuilds a formatted json array of 
# comments out of the original json array of comments.
#
# + comments - Original json array of comments.  
# + return   - Returns a formatted **json[]** of comments, **error** if a formatted 
# json array of comments cannot be rebuilt.
public function createAFormattedJsonOfComments(json[] comments) returns json[] | error {

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

# The `isValidComment` function checks whether a comment with the provided comment id exists.
#
# + commentId - Comment Id related to the comment. 
# + return    - Returns a **boolean** which indicates whether the comment exists or not, 
# returns an **error** if the github response is not in the expected form.
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

# The `isValidCommentOfUser` function checks whether a comment with the provided comment id is created by the 
# given user.
#
# + commentId - Comment Id related to the comment. 
# + userName - Name of the user.
# + return    - Returns a **boolean** which indicates whether the comment is created by the given user or
# returns an **error** if the github response is not in the expected form.
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
                return error("The json payload received from the github response is not in form of json.");
            }
        } else {
            return error("The comment id specified is not a valid comment.");
        }
    } else {
        return error("The github response is not in the expected form: http:Response.");
    }
}
