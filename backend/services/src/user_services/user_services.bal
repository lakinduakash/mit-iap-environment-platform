import utilities;
import ballerina/http;
import ballerina/lang.'int as ints;
import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (USER_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}

service userService on endPoint {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-request/{userName}/{issueNumber}"
    }
    resource function getRequest(http:Caller caller, http:Request request, string userName, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            json | error jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json) {
                json | error formattedIssue = utilities:createAFormattedJsonOfAnIssue(jsonPayload);
                if (formattedIssue is json) {
                    if (utilities:userNameExists(<json[]>formattedIssue.labels, userName)) {
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
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
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
        path: "/get-requests/{userName}"
    }
    resource function getRequests(http:Caller caller, http:Request request, string userName) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=all";

        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error issues = utilities:extractIssuesRelatedToUser(jsonPayload, userName);
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
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Invalid json payload received from github response.");
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
        path: "/post-request/{userName}"
    }
    resource function postRequest(http:Caller caller, http:Request request, string userName) {

        http:Response response = new;
        http:Request callBackRequest = new;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues";

        var receivedRequestPayload = request.getJsonPayload();
        if (receivedRequestPayload is json) {
            json | error payloadTitle = receivedRequestPayload.title;
            json | error payloadBody = receivedRequestPayload.body;
            if (payloadTitle is json && payloadBody is json) {
                string stringPayloadBody = payloadBody.toJsonString();
                callBackRequest.setPayload(<@untained>({"title": payloadTitle, "body": stringPayloadBody}));
                http:Response | error githubResponse = githubAPIEndpoint->post(url, callBackRequest);
                if (githubResponse is http:Response && githubResponse.statusCode == 201) {
                    string[] createLabelResult = utilities:createLabel(<@untained>userName, "userName");
                    int | error createLabelResultCode = ints:fromString(createLabelResult[0]);
                    if (createLabelResultCode is int && (createLabelResultCode == 201 || createLabelResultCode == 422)) {
                        json | error githubResponsePayload = githubResponse.getJsonPayload();
                        if (githubResponsePayload is json) {
                            string issueNumber = githubResponsePayload.number.toString();
                            string[] assignLabelResult = utilities:assignLabel(<@untained>issueNumber, [userName]);
                            int | error assignLabelResultCode = ints:fromString(assignLabelResult[0]);
                            if (assignLabelResultCode is int && assignLabelResultCode == 200) {
                                response.statusCode = 201;
                                response.setPayload(assignLabelResult[1]);
                            } else {
                                log:printError("Either the status code for assigning label is not a integer or it is invalid");
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload("Error in the status code for assigning label.");
                            }
                        } else {
                            log:printError("Error while extracting the json payload from the github response");
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload(<@untained>githubResponsePayload.reason());
                        }
                    } else {
                        log:printError("Either the status code for creating label is not a integer or it is invalid");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Error in the status code for creating label.");
                    }
                } else {
                    log:printError("Error while obtaining the response from github api services.");
                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                    response.setPayload("Error while obtaining the response from github api services.");
                }
            } else {
                log:printInfo("Error while obtaining the json payload body/title from the request received.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Error while obtaining the json payload body/title from the request received.");
            }
        } else {
            log:printInfo("Error while obtaining the json payload from the request received.");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setPayload("Error while obtaining the json payload from the request received.");
        }

        error? respond = caller->respond(response);
    }

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
        path: "/post-comment/{issueNumber}/{userName}"
    }
    resource function postCommentOnIssue(http:Caller caller, http:Request request, string issueNumber, string userName) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = utilities:isValidIssue(<@untained>issueNumber);
        boolean | error validUser = utilities:isValidUserOnIssue(userName, <@untainted>issueNumber);
        if (validIssue is boolean) {
            if (validUser is boolean) {
                if (validIssue) {
                    if (validUser) {
                        var receivedRequestPayload = request.getJsonPayload();
                        if (receivedRequestPayload is json) {
                            json | error payloadContent = receivedRequestPayload.body;
                            if (payloadContent is json) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->post(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 201) {
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
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                log:printInfo("Invalid payload content extracted.");
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload(<@untained>payloadContent.reason());
                            }
                        } else {
                            log:printInfo("Invalid json payload extracted.");
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload("Invalid json payload extracted.");
                        }
                    } else {
                        log:printInfo("Issue with the given user name does not exist.");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Issue with the given user name does not exist.");
                    }
                } else {
                    log:printInfo("Issue with the given issue number does not exist.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Issue with the given issue number does not exist.");
                }
            } else {
                log:printInfo("Error occurred while checking the validity of the user");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload(validUser.reason());
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the issue");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validIssue.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["PATCH"],
        path: "/edit-comment/{commentId}/{userName}/{issueNumber}"
    }
    resource function editCommentOnIssue(http:Caller caller, http:Request request, string commentId, string userName, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validComment = utilities:isValidCommentOfUser(<@untained>commentId, <@untainted>userName);
        boolean | error validUser = utilities:isValidUserOnIssue(<@untainted>userName, <@untainted>issueNumber);
        if (validUser is boolean) {
            if (validComment is boolean) {
                if (validUser) {
                    if (validComment) {
                        var receivedRequestPayload = request.getJsonPayload();
                        if (receivedRequestPayload is json) {
                            json | error payloadContent = receivedRequestPayload.body;
                            if (payloadContent is json) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->patch(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 200) {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Comment updated successfully.");
                                    } else {
                                        log:printInfo("The github response status was: " + githubResponse.statusCode.toString()
                                        + " instead of 200");
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Comment was not updated successfully.");
                                    }
                                } else {
                                    log:printInfo("The github response is not in the expected form: http:Response.");
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                log:printInfo("Invalid payload content extracted.");
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload(<@untained>payloadContent.reason());
                            }
                        } else {
                            log:printInfo("Invalid json payload extracted.");
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload("Invalid json payload extracted.");
                        }
                    } else {
                        log:printInfo("Comment with the given comment id does not exist.");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Comment with the given comment id does not exist.");
                    }
                } else {
                    log:printInfo("Issue with the given user name does not exist.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Issue with the given user name does not exist.");
                }
            } else {
                log:printInfo("Error occurred while checking the validity of the comment");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload(validComment.reason());
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the user");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validUser.reason());
        }
        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/delete-comment/{commentId}/{userName}/{issueNumber}"
    }
    resource function deleteCommentOnIssue(http:Caller caller, http:Request request, string commentId, string userName, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validComment = utilities:isValidCommentOfUser(<@untained>commentId, <@untainted>userName);
        boolean | error validUser = utilities:isValidUserOnIssue(<@untainted>userName, <@untainted>issueNumber);
        if (validUser is boolean) {
            if (validComment is boolean) {
                if (validUser) {
                    if (validComment) {
                        http:Response | error githubResponse = githubAPIEndpoint->delete(<@untained>url, callBackRequest);
                        if (githubResponse is http:Response) {
                            if (githubResponse.statusCode == 204) {
                                response.statusCode = githubResponse.statusCode;
                                response.setPayload("Comment deleted successfully.");
                            } else {
                                log:printInfo("The github response status was: " + githubResponse.statusCode.toString()
                                + " instead of 204");
                                response.statusCode = githubResponse.statusCode;
                                response.setPayload("Comment was not deleted successfully.");
                            }
                        } else {
                            log:printInfo("The github response is not in the expected form: http:Response.");
                            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                            response.setPayload(githubResponse.reason());
                        }
                    } else {
                        log:printInfo("Comment with the given comment id does not exist.");
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Comment with the given comment id does not exist.");
                    }
                } else {
                    log:printInfo("Issue with the given user name does not exist.");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Issue with the given user name does not exist.");
                }
            } else {
                log:printInfo("Error occurred while checking the validity of the comment");
                response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                response.setPayload(validComment.reason());
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the user");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validUser.reason());
        }
        error? respond = caller->respond(response);
    }
}
