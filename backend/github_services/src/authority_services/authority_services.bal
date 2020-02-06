import utilities;
import ballerina/http;
import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (AUTHORITY_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}

service authorityService on endPoint {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-comments/{issueNumber}"
    }
    resource function getComments(http:Caller caller, http:Request request, string issueNumber) returns @untainted error? {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json[] | error comments = utilities:createFormattedComments(jsonPayload);
                if (comments is json[]) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload(<@untained>comments);
                } else {
                    log:printInfo("The comments related to issue could not be converted to json.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>comments.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_BAD_REQUEST;
                response.setPayload("Invalid payload received from github response.");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/post-comment/{issueNumber}"
    }
    resource function postCommentOnIssue(http:Caller caller, http:Request request, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = utilities:isValidIssue(<@untained>issueNumber);
        if (validIssue is boolean) {
            if (validIssue) {
                var receivedRequestPayload = request.getJsonPayload();
                if (receivedRequestPayload is json) {
                    json | error payloadContent = receivedRequestPayload.body;
                    if (payloadContent is json) {
                        callBackRequest.setPayload(<@untained>receivedRequestPayload);
                        http:Response | error githubResponse = githubAPIEndpoint->post(<@untained>url, callBackRequest);
                        if (githubResponse is http:Response) {
                            if (githubResponse.statusCode == http:STATUS_CREATED) {
                                response.statusCode = githubResponse.statusCode;
                                response.setPayload("Comment added successfully.");
                            } else {
                                log:printInfo("The github response status was: " + githubResponse.statusCode.toString()
                                + " instead of 201");
                                response.statusCode = githubResponse.statusCode;
                                response.setPayload("Comment was not added successfully.");
                            }
                        } else {
                            log:printInfo("The github response is not in the expected form: http:Response.");
                            response.statusCode = http:STATUS_BAD_REQUEST;
                            response.setPayload(githubResponse.reason());
                        }
                    } else {
                        log:printInfo("Invalid payload content extracted from the received request.");
                        response.statusCode = http:STATUS_BAD_REQUEST;
                        response.setPayload(<@untained>payloadContent.reason());
                    }
                } else {
                    log:printInfo("Invalid json payload extracted from the received request.");
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setPayload("Invalid json payload extracted from the received request.");
                }
            } else {
                log:printInfo("Issue with the given issue number does not exist.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the issue.");
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setPayload(validIssue.reason());
        }
        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-requests/{authorityName}"
    }
    resource function getRequests(http:Caller caller, http:Request request, string authorityName) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=all";

        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error issues = utilities:extractIssuesRelatedToAuthority(jsonPayload, authorityName);
                if (issues is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload(<@untained>issues);
                } else {
                    log:printInfo("The issues related to authority could not be converted to json.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>issues.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_BAD_REQUEST;
                response.setPayload("Invalid json payload received from github response.");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }
}
