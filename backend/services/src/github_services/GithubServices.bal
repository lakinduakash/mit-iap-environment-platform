import ballerina/http;
// import ballerina/io;
import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (PORT);

@http:ServiceConfig {
    basePath: BASEPATH
}
service githubConnector on endPoint {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/create-label/{userName}/{repoName}"
    }
    resource function createLabel(http:Caller caller, http:Request request, string userName, string repoName) returns @untainted error? {
        var content = request.getJsonPayload();
        if content is json {
            json labelName = check content.labelName;
            json labelDescription = check content.labelDescription;
            json status = createLabel(<@untained>userName, <@untained>repoName, <@untained>labelName.toString(), <@untained>labelDescription.toString());
            error? result = caller->respond(status);
        } else {
            log:printError("The Content is not formatted.");
            error? result = caller->respond({"statusCode": http:STATUS_NOT_ACCEPTABLE, "status": "Not Acceptable"});
        }
    }
}

// public function main() {


//     io:println(checkLabel("bugii", "yashodgayashan", "ballerina-github-connector"));
//     io:println(createLabel("yashodgayashan", "ballerina-github-connector", "bugiii", "test"));
// }

