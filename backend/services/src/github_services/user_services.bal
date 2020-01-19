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
        path: "/get-request-for-user/{userName}/{issueNumber}"
    }
    resource function getRequestRelatedToUser(http:Caller caller, http:Request request, string userName, string issueNumber) {

        // http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber;

        // callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        // http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url);

        if (githubResponse is http:Response) {
            json | error jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json) {
                json | error formattedIssue = createAFormattedJsonOfAnIssue(jsonPayload);
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
        path: "/get-requests-for-user/{userName}"
    }
    resource function getRequestsRelatedToUser(http:Caller caller, http:Request request, string userName) {

        // http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues?state=all";

        // callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        // http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);
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
        path: "/create-label"
    }
    resource function createLabel(http:Caller caller, http:Request request) {

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
    resource function assignLabel(http:Caller caller, http:Request request, string issueNumber) {

        http:Response response = new;
        var jsonPayload = request.getJsonPayload();

        if (jsonPayload is json) {
            json | error labels = jsonPayload.labelNames;
            if labels is json {
                json[] | error labelArray = trap <json[]>labels;
                if (labelArray is json[]) {
                    string[] status = assignLabel(<@untainted>issueNumber,<@untainted > toStringArray(labelArray));
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
                json | error formattedLabels = createAFormattedJsonOfLabels(jsonPayload);
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
                callBackRequest.setPayload(<@untained> ({"title": payloadTitle, "body": stringPayloadBody}));
                http:Response | error githubResponse = githubAPIEndpoint->post(url, callBackRequest);
                if (githubResponse is http:Response && githubResponse.statusCode == 201) {
                    string[] createLabelResult = createLabel(<@untained>userName, "Name of the user.");
                    int | error createLabelResultCode = ints:fromString(createLabelResult[0]);
                    if (createLabelResultCode is int && createLabelResultCode == 201) {
                        json | error githubResponsePayload = githubResponse.getJsonPayload();
                        if (githubResponsePayload is json) {
                            string issueNumber = githubResponsePayload.number.toString();
                            string[] assignLabelResult = assignLabel(<@untained>  issueNumber, [userName]);
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
        methods: ["PATCH"],
        path: "/edit-request/{issueNumber}"
    }
    resource function editRequest(http:Caller caller, http:Request request, string issueNumber) {

        http:Response response = new;
        http:Request callBackRequest = new;
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" +issueNumber;

        var receivedRequestPayload = request.getJsonPayload();
        if (receivedRequestPayload is json) {
            json | error payloadTitle = receivedRequestPayload.title;
            json | error payloadBody = receivedRequestPayload.body;
            json | error payloadState = receivedRequestPayload.state;
            if (payloadTitle is json && payloadBody is json && payloadState is json) {
                string stringPayloadBody = payloadBody.toJsonString();
                callBackRequest.setPayload(<@untained> ({"title": payloadTitle, "body": stringPayloadBody, "state": payloadState}));
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

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-all-collaborators"
    }
    resource function getAllCollaborators(http:Caller caller, http:Request request) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators";

        // Please change the scope of the access token to make the function work
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error collaboratorDetails = createAFormattedJsonOfCollaborators(jsonPayload);
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

        boolean | error isACollaborator = isValidCollaborator(<@untained>userName);
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

        boolean | error isACollaborator = isValidCollaborator(<@untained>userName);
        if (isACollaborator is boolean) {
            if (isACollaborator) {
                http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);
                if (githubResponse is http:Response) {
                    if (githubResponse.statusCode == 204) {
                        response.statusCode = githubResponse.statusCode;
                        response.setPayload("Collaborator wad removed successfully.");
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

        // Please change the scope of the access token to make the function work
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = githubAPIEndpoint->get(<@untained>url, callBackRequest);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            if (jsonPayload is json[]) {
                json | error assigneeDetails = createAFormattedJsonOfAssignees(jsonPayload);
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

        // Please change the scope of the access token to make the function work
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = isValidIssue(<@untained>issueNumber);
        if (validIssue is boolean) {
            if (validIssue) {
                var receivedRequestPayload = request.getJsonPayload();
                if (receivedRequestPayload is json) {
                    json | error payloadContent = receivedRequestPayload.assignees;
                    if (payloadContent is json) {
                        boolean | error validOperation = areValidAssignees(<@untained><json[]>payloadContent);
                        if (validOperation is boolean) {
                            if (validOperation) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->post(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 201) {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees added successfully.");
                                    } else {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees were not added successfully.");
                                    }
                                } else {
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload("One or more of the assignees passed cannot be assigned");
                            }
                        } else {
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload(validOperation.reason());
                        }
                    } else {
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Invalid payload content extracted.");
                    }
                } else {
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Invalid json payload extracted.");
                }
            } else {
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Error occurred while checking the validity of the issue");
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

        // Please change the scope of the access token to make the function work
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = isValidIssue(<@untained>issueNumber);
        if (validIssue is boolean) {
            if (validIssue) {
                var receivedRequestPayload = request.getJsonPayload();
                if (receivedRequestPayload is json) {
                    json | error payloadContent = receivedRequestPayload.assignees;
                    if (payloadContent is json) {
                        boolean | error validOperation = areValidAssignees(<@untained><json[]>payloadContent);
                        if (validOperation is boolean) {
                            if (validOperation) {
                                callBackRequest.setPayload(<@untained>receivedRequestPayload);
                                http:Response | error githubResponse = githubAPIEndpoint->delete(<@untained>url, callBackRequest);
                                if (githubResponse is http:Response) {
                                    if (githubResponse.statusCode == 200) {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees removed successfully.");
                                    } else {
                                        response.statusCode = githubResponse.statusCode;
                                        response.setPayload("Assignees were not removed successfully.");
                                    }
                                } else {
                                    response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                                    response.setPayload(githubResponse.reason());
                                }
                            } else {
                                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                response.setPayload("One or more of the assignees passed cannot be unassigned");
                            }
                        } else {
                            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            response.setPayload(validOperation.reason());
                        }
                    } else {
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Invalid payload content extracted.");
                    }
                } else {
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Invalid json payload extracted.");
                }
            } else {
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Error occurred while checking the validity of the issue");
        } 

        error? respond = caller->respond(response);
    }

    

    @http:ResourceConfig {
        methods: ["POST"],
        path: "admin/post-comment/{issueNumber}"
    }
    resource function postCommentOnIssue(http:Caller caller, http:Request request, string issueNumber) {

        http:Request callBackRequest = new;
        http:Response response = new;
        string url = "/repos/" + ORGANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";

        // Please change the scope of the access token to make the function work
        callBackRequest.addHeader("Authorization", ACCESS_TOKEN);

        boolean | error validIssue = isValidIssue(<@untained>issueNumber);
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
                                response.statusCode = githubResponse.statusCode;
                                response.setPayload("Comment was not added successfully.");
                            }
                        } else {
                            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
                            response.setPayload(githubResponse.reason());
                        }
                    } else {
                        response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        response.setPayload("Invalid payload content extracted.");
                    }
                } else {
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    response.setPayload("Invalid json payload extracted.");
                }
            } else {
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                response.setPayload("Issue with the given issue number does not exist.");
            }
        } else {
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Error occurred while checking the validity of the issue");
        } 

        error? respond = caller->respond(response);
    }
}
