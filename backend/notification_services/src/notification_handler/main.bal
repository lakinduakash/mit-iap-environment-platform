import ballerina/io;
import ballerina/http;

type Notification record {
    string issueCreator?;
    string receiver;
    string category;
    string description;
};

@http:ServiceConfig {
    basePath: "/"
}
service eventListener on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/event",
        methods: ["POST"]
    }
    resource function getEvent(http:Caller caller, http:Request request) {

        var data = request.getJsonPayload();
        if (data is json) {
            io:println(data.toJsonString());
        }
    
    }
}

