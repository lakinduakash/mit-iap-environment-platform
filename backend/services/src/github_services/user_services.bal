import ballerina/http;
import ballerina/io;
import ballerina/lang.'int as ints;
import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}

service userService on endPoint {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-request-for-user/{userName}/{issueNumber}"
    }
    resource function getRequestRelatedToUser(http:Caller caller, http:Request req, string userName, string issueNumber) returns error? {

        // http:Request request = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

        // request.addHeader("Authorization", ACCESS_TOKEN);
        // http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, request);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url);

        if (githubResponse is http:Response) {
            json | error jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json) {
                json | error formattedIssue = createFormattedIssue(jsonPayload);
                if (formattedIssue is json) {
                    if (userNameExists(<json[]>formattedIssue.labels, userName)) {
                        response.statusCode = http:STATUS_OK;
                        response.setJsonPayload(<@untained>formattedIssue);
                    } else {
                        log:printInfo("Issue is not related to the username specified.");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Issue is not related to the username specified.");
                    }
                } else {
                    log:printInfo("Error occurred during the process of formatting the issue.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>formattedIssue.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload(<@untained>jsonPayload.reason());
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-requests-for-user/{userName}"
    }
    resource function getRequestsRelatedToUser(http:Caller caller, http:Request req, string userName) returns error? {

        // http:Request request = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=all";

        // request.addHeader("Authorization", ACCESS_TOKEN);
        // http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, request);
        http:Response | error githubResponse = githubAPIEndpoint->get(url);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error issues = extractIssuesRelatedToUser(jsonPayload, userName);
                if (issues is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload(<@untained>issues);
                } else {
                    log:printInfo("The issues related to user could not be converted to json.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>issues.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload("Invalid payload received from github response.");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/create-label"
    }
    resource function createLabel(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        var jsonPayload = request.getJsonPayload();

        if jsonPayload is json {
            json | error labelName = jsonPayload.labelName;
            json | error labelDescription = jsonPayload.labelDescription;
            if (labelName is json && labelDescription is json) {
                string[] status = createLabelIfNotExists(<@untained>labelName.toString(), <@untained>labelDescription.toString());
                int | error statusCode = ints:fromString(status[0]);
                if (statusCode is int) {
                    response.statusCode = statusCode;
                    response.setPayload(status[1]);
                } else {
                    log:printError("Integer conversion error as the retrived status code from the github is invalid. Check createLabel function");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Internal server error occured.");
                }
            } else {
                log:printError("Invalid json payload received from the response.");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload("Not acceptable payload");
            }
        } else {
            log:printError("Invalid payload type received from the response.");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Not acceptable payload type");
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/assign-label/{issueNumber}"
    }
    resource function assignLabel(http:Caller caller, http:Request request, string issueNumber) returns @untainted error? {

        http:Response response = new;
        var jsonPayload = request.getJsonPayload();

        if (jsonPayload is json) {
            json | error labels = jsonPayload.labelNames;
            if labels is json {
                string[] lane = <string[]>labels;
                io:println(lane[0].toString());
            }
        }

    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-labels"
    }
    resource function getAllLabels(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

        http:Response | error githubResponse = githubAPIEndpoint->get(url);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json labelDetails = check createFormattedLabels(jsonPayload);
                response.setJsonPayload(<@untained>labelDetails);
            } else {
                log:printInfo("Invalcheckid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Invalid payload received from github response.");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/post-request/{userName}"
    }
    resource function postRequest(http:Caller caller, http:Request request, string userName) returns @untainted error? {

        http:Response response = new;
        http:Request callBackRequest = new;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues";

        var receivedRequestPayload = request.getJsonPayload();
        if (receivedRequestPayload is json) {
            json | error payloadBody = receivedRequestPayload.body;
            if (payloadBody is json) {
                string stringPayloadBody = payloadBody.toJsonString();
                http:Response | error githubResponse = githubAPIEndpoint->post(url, callBackRequest);
                if (githubResponse is http:Response && githubResponse.statusCode == 201) {
                    string[] status = createLabel(<@untained>userName, "Name of the user.");
                    int | error statusCode = ints:fromString(status[0]);
                    if (statusCode is int && statusCode == 201) {
                        // Store issue id using gihubResponse.
                        // Assign the label here.
                        response.statusCode = statusCode;
                        response.setPayload(status[1]);
                    } else {
                        log:printError("Either the status code is not a integer or the status code is invalid");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Error while obtaining the status from the response.");
                    }
                } else {
                    log:printError("Error while obtaining the response from github api services.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Error while obtaining the response from github api services.");
                }
            } else {
                log:printInfo("Error while obtaining the json payload body from the request sent.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Error while obtaining the json payload body from the request sent.");
            }
        } else {
            log:printInfo("Error while obtaining the json payload from the request sent.");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setPayload("Error while obtaining the json payload from the request sent.");
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-collaborators"
    }
    resource function getAllCollaborators(http:Caller caller, http:Request request) returns @untainted error? {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators";

        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error collaboratorDetails = createFormattedCollaborators(jsonPayload);
                if (collaboratorDetails is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setPayload(<@untained>collaboratorDetails);
                } else {
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>collaboratorDetails.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Invalid payload received from github response.");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response.");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }
}
