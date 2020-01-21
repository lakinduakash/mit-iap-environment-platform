import ballerina/http;
import ballerina/io;

type Notification record {
    // string issueCreator?;
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
            if (data.action is json) {
                var  event_action = data.action;
                if (event_action == "opened" ) {
                    // Issue created
                    Notification notification = {
                        receiver: "admin",
                        category: "Issue Created",
                        description: "New request was created"
                    };
                    io:println(notification);
                } else if (event_action == "edited") {
                    // Issue Edited
                    Notification notification = {
                        receiver: "admin",
                        category: "Issue Edited",
                        description: "New request was created"
                    };
                    io:println(notification);
                } else if (event_action == "closed") {
                    // Issue Closed
                    // Notification to the admin
                    Notification notification = {
                        receiver: "admin",
                        category: "Issue Closed",
                        description: "Request deleted"
                    };
                    io:println(notification);
                } else if (event_action == "created") {
                    // Comment Created
                    if (data.comment is json) {
                        var comment_body = data.comment.body;
                        // var username = "";
                        // if (data.issue.labels is json) {
                        //     json|error labels = data.issue.labels;
                        //     if (labels is json) {
                        //         username = labels[0].name;
                        //     }
                        // }
                        // Send notification to user
                        Notification notification = {
                            receiver: "admin",
                            category: "Comment Created",
                            description: "New comment was added."
                        };
                        io:println(notification);
                    }
                } else if (event_action == "labeled") {
                    // Issue was labeled
                    Notification notification = {
                        receiver: "admin",
                        category: "Label Added ",
                        description: "New label was added"
                    };
                    io:println(notification);
                }
            }
        }
    
    }
}

