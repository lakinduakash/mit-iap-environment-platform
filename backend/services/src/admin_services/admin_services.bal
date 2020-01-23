import utilities;
import ballerina/http;
import ballerina/lang.'int as ints;
import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (ADMIN_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}

service adminService on endPoint {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/create-label"
    }
    resource function createLabel(http:Caller caller, http:Request request) {

        http:Response response = new;
        var jsonPayload = request.getJsonPayload();

        if jsonPayload is json {
            json | error labelName = jsonPayload.labelName;
            json | error labelDescription = jsonPayload.labelDescription;
            if (labelName is json && labelDescription is json) {
                string[] status = utilities:createLabelIfNotExists(<@untained>labelName.toString(), <@untained>labelDescription.toString());
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
    resource function assignLabel(http:Caller caller, http:Request request, string issueNumber) {

        http:Response response = new;
        var jsonPayload = request.getJsonPayload();

        if (jsonPayload is json) {
            json | error labels = jsonPayload.labelNames;
            if labels is json {
                json[] | error labelArray = trap <json[]>labels;
                if (labelArray is json[]) {
                    string[] status = utilities:assignLabel(<@untainted>issueNumber, <@untainted>utilities:toStringArray(labelArray));
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
        methods: ["DELETE"],
        path: "/remove-label/{issueNumber}/{label}"
    }
    resource function removeLabel(http:Caller caller, http:Request request, string issueNumber, string label) {

        http:Response response = new;

        int status = utilities:removeLabel(<@untainted>issueNumber, <@untainted>label);
        if (status == http:STATUS_OK) {
            response.statusCode = status;
            response.setPayload("Label removed from the request successfully.");
        } else {
            log:printInfo("Label was not removed since the request sent was a bad request.");
            response.statusCode = status;
            response.setPayload("Label was not removed from the request successfully.");
        }
        
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-labels"
    }
    resource function getAllLabels(http:Caller caller, http:Request request) {

        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

        http:Response | error githubResponse = githubAPIEndpoint->get(url);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error formattedLabels = utilities:createAFormattedJsonOfLabels(jsonPayload);
                if (formattedLabels is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload(<@untained>formattedLabels);
                } else {
                    log:printInfo("Error occured during the process of rebuiliding the list of labels");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setJsonPayload(<@untained>formattedLabels.reason());
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
        methods: ["GET"],
        path: "/get-all-collaborators"
    }
    resource function getAllCollaborators(http:Caller caller, http:Request request) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error collaboratorDetails = utilities:createAFormattedJsonOfCollaborators(jsonPayload);
                if (collaboratorDetails is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setPayload(<@untained>collaboratorDetails);
                } else {
                    log:printInfo("Error occured during the process of rebuiliding the list of collaborators");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>collaboratorDetails.reason());
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
        methods: ["PUT"],
        path: "/add-collaborator/{userName}"
    }
    resource function addCollaborator(http:Caller caller, http:Request request, string userName) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators/" + userName;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error isACollaborator = utilities:isValidCollaborator(<@untained>userName);
        if (isACollaborator is boolean) {
            if (!isACollaborator) {
                http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);
                if (githubResponse is http:Response) {
                    if (githubResponse.statusCode == 201) {
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Collaborator added successfully.");
                    } else {
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Collaborator was not added successfully.");
                    }
                } else {
                    log:printInfo("The github response is not in the expected form: http:Response.");
                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                    response.setPayload(githubResponse.reason());
                }
            } else {
                log:printInfo("The user is already a collaborator in the repository");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("The user is already a collaborator");
            }
        } else {
            log:printInfo("Error occurred while checking whether the collaborator already exists");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(isACollaborator.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/remove-collaborator/{userName}"
    }
    resource function removeCollaborator(http:Caller caller, http:Request request, string userName) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators/" + userName;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error isACollaborator = utilities:isValidCollaborator(<@untained>userName);
        if (isACollaborator is boolean) {
            if (isACollaborator) {
                http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);
                if (githubResponse is http:Response) {
                    if (githubResponse.statusCode == 204) {
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Collaborator removed successfully.");
                    } else {
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Collaborator was not removed successfully.");
                    }
                } else {
                    log:printInfo("The github response is not in the expected form: http:Response.");
                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                    response.setPayload(githubResponse.reason());
                }
            } else {
                log:printInfo("The user is not a collaborator in the repository");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("The user is not a collaborator");
            }
        } else {
            log:printInfo("Error occurred while checking whether the collaborator already exists");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(isACollaborator.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-assignees"
    }
    resource function getAllAssignees(http:Caller caller, http:Request request) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/assignees";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error assigneeDetails = utilities:createAFormattedJsonOfAssignees(jsonPayload);
                if (assigneeDetails is json) {
                    response.statusCode = http:STATUS_OK;
                    response.setPayload(<@untained>assigneeDetails);
                } else {
                    log:printInfo("Error occured during the process of rebuiliding the list of assignees");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload(<@untained>assigneeDetails.reason());
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
        path: "/add-assignees/{issueNumber}"
    }
    resource function addAssigneesToIssue(http:Caller caller, http:Request request, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/assignees";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = utilities:isValidIssue(<@untained>issueNumber);
        if (validIssue is boolean) {
            if (validIssue) {
                var receivedRequestPayload = request.getJsonPayload();
                if (receivedRequestPayload is json) {
                    json | error payloadContent = receivedRequestPayload.assignees;
                    if (payloadContent is json) {
                        boolean | error validOperation = utilities:areValidAssignees(<@untained><json[]>payloadContent);
                        if (validOperation is boolean) {
                            if (validOperation) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->post(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 201) {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees added successfully.");
                                    } else {
                                        log:printInfo("The github response status was: " + githubResponse.statusCode.toString() +
                                        " instead of 201");
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees were not added successfully.");
                                    }
                                } else {
                                    log:printInfo("The github response is not in the expected form: http:Response.");
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                log:printInfo("One or more of the assignees passed cannot be assigned because" +
                                "they do not have the relevant permissions required.");
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload("One or more of the assignees passed cannot be assigned");
                            }
                        } else {
                            log:printInfo("Error occurred while checking the validity of the assignees");
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload(validOperation.reason());
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
                log:printInfo("Issue with the given issue number does not exist.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the issue");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validIssue.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/remove-assignees/{issueNumber}"
    }
    resource function removeAssigneesFromIssue(http:Caller caller, http:Request request, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/assignees";
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = utilities:isValidIssue(<@untained>issueNumber);
        if (validIssue is boolean) {
            if (validIssue) {
                var receivedRequestPayload = request.getJsonPayload();
                if (receivedRequestPayload is json) {
                    json | error payloadContent = receivedRequestPayload.assignees;
                    if (payloadContent is json) {
                        boolean | error validOperation = utilities:areValidAssignees(<@untained><json[]>payloadContent);
                        if (validOperation is boolean) {
                            if (validOperation) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->delete(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 200) {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees removed successfully.");
                                    } else {
                                        log:printInfo("The github response status was: " + githubResponse.statusCode.toString() +
                                        " instead of 200");
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees were not removed successfully.");
                                    }
                                } else {
                                    log:printInfo("The github response is not in the expected form: http:Response.");
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                log:printInfo("One or more of the assignees passed cannot be unassigned because" +
                                "they do not have the relevant permissions required or they are not assigned yet.");
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload("One or more of the assignees passed cannot be unassigned");
                            }
                        } else {
                            log:printInfo("Error occurred while checking the validity of the assignees");
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload(validOperation.reason());
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
                log:printInfo("Issue with the given issue number does not exist.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            log:printInfo("Error occurred while checking the validity of the issue");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validIssue.reason());
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
                log:printInfo("Issue with the given issue number does not exist.");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
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
        path: "/edit-comment/{commentId}"
    }
    resource function editCommentOnIssue(http:Caller caller, http:Request request, string commentId) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validComment = utilities:isValidComment(<@untained>commentId);
        if (validComment is boolean) {
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
            log:printInfo("Error occurred while checking the validity of the comment");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validComment.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/delete-comment/{commentId}"
    }
    resource function deleteCommentOnIssue(http:Caller caller, http:Request request, string commentId) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/comments/" + commentId;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validComment = utilities:isValidComment(<@untained>commentId);
        if (validComment is boolean) {
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
            log:printInfo("Error occurred while checking the validity of the comment");
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload(validComment.reason());
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-requests"
    }
    resource function getAllRequests(http:Caller caller, http:Request request) returns @untainted error? {

        http:Request calBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=all";

        calBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, calBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json[] | error issues = utilities:createFormattedIssues(jsonPayload);
                if (issues is json[]) {
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
        methods: ["PATCH"],
        path: "/edit-request/{issueNumber}"
    }
    resource function editRequest(http:Caller caller, http:Request request, string issueNumber) {

        http:Response response = new;
        http:Request callBackRequest = new;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

        var receivedRequestPayload = request.getJsonPayload();
        if (receivedRequestPayload is json) {
            json | error payloadTitle = receivedRequestPayload.title;
            json | error payloadBody = receivedRequestPayload.body;
            json | error payloadState = receivedRequestPayload.state;
            if (payloadTitle is json && payloadBody is json && payloadState is json) {
                string stringPayloadBody = payloadBody.toJsonString();
                callBackRequest.setPayload(<@untained>({"title": payloadTitle, "body": stringPayloadBody, "state": payloadState}));
                http:Response | error githubResponse = githubAPIEndpoint->patch(<@untained>url, callBackRequest);
                if (githubResponse is http:Response) {
                    if (githubResponse.statusCode == 200) {
                        response.statusCode = http:STATUS_OK;
                        response.setPayload(<@untained>("Updated issue number: " + issueNumber));
                    } else {
                        log:printError("Github response status code was not 200 OK.");
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Issue was not updated succesfully. Please check the issue number");
                    }
                } else {
                    log:printError("Error while obtaining the response from github api services.");
                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                    response.setPayload(githubResponse.reason());
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
}
