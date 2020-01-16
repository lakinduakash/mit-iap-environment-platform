import ballerina/http;
import ballerina/io;
import ballerina/log;

const string organizationName = "yashodgayashan";
const string repositoryName = "ballerina-github-connector";
// const string ACCESS_TOKEN = "Bearer <token-id>";

http:Client clientEndpoint = new ("https://api.github.com");

@http:ServiceConfig {
    basePath: "/github",
    cors: {
        allowOrigins: ["*"]
    }
}

service userService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-requests-for-user/{userName}"
    }
    resource function getRequestsRelatedToUser(http:Caller caller, http:Request req, string userName) returns error? {

        // http:Request request = new;
        http:Response response = new;
        string url = "/repos/" + organizationName + "/" + repositoryName + "/issues?state=all";

        // request.addHeader("Authorization", ACCESS_TOKEN);
        http:Response | error githubResponse = clientEndpoint->get(url);

        if (githubResponse is http:Response) {
            var jsonPayload = githubResponse.getJsonPayload();
            io:println(jsonPayload);
            if (jsonPayload is json[]) {
                json | error issues = extractIssuesRelatedToUser(jsonPayload, userName);
                if (issues is json) {
                    response.statusCode = 200;
                    response.setJsonPayload(<@untained>issues);
                } else {
                    log:printInfo("The issues related to user could not be converted to json");
                    response.statusCode = 500;
                    response.setPayload(<@untained>issues.reason());
                }
            } else {
                log:printInfo("Invalid json payload received from the response obtained from github");
                response.statusCode = 500;
                response.setPayload("Invalid payload received from github response");
            }
        } else {
            log:printInfo("The github response is not in the expected form: http:Response");
            response.statusCode = 500;
            response.setPayload(<@untained>githubResponse.reason());
        }

        error? respond = caller->respond(response);
    }
}
