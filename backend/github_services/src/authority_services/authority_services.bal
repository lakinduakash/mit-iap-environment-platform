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
}
