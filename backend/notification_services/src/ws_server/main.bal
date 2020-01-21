import ballerina/io;
import ballerina/log;
import ballerina/http;

string ping = "ping";
byte[] pingData = ping.toBytes();

http:WebSocketCaller[] wsClients=[];

public type WsUser record {
    string user;
    http:WebSocketCaller wsCaller;
};

WsUser[] wsUsers=[];

@http:WebSocketServiceConfig {
    path: "/notifications",
    subProtocols: ["xml", "json"],
    idleTimeoutInSeconds: 120
}
service basic on new http:Listener(9095) {
    resource function onOpen(http:WebSocketCaller caller) {
        io:println("\nNew client connected");
        io:println("Connection ID: " + caller.getConnectionId());
        io:println("Negotiated Sub protocol: " + caller.getNegotiatedSubProtocol().toString());
        io:println("Is connection open: " + caller.isOpen().toString());
        io:println("Is connection secured: " + caller.isSecure().toString());

        wsClients.push(caller);
    }
    resource function onText(http:WebSocketCaller caller, string text,
                                boolean finalFrame) {
        io:println("\ntext message: " + text + " & final fragment: "
                                                        + finalFrame.toString());
        if (text == "ping") {
            io:println("Pinging...");
            var err = caller->ping(pingData);
            if (err is http:WebSocketError) {
                log:printError("Error sending ping", err);
            }
        } else if (text == "closeMe") {
            error? result = caller->close(statusCode = 1001,
                            reason = "You asked me to close the connection",
                            timeoutInSeconds = 0);
            if (result is http:WebSocketError) {
                log:printError("Error occurred when closing connection", result);
            }
        } else {
            var err = caller->pushText("You said: " + text);
            WsUser c = {
                user:text,
                wsCaller:caller
                };

            foreach var item in wsUsers {
                if item.wsCaller.getConnectionId() !== caller.getConnectionId(){
                    wsUsers.push(c);
                    break;
                }
            }


            if (err is http:WebSocketError) {
                log:printError("Error occurred when sending text", err);
            }
        }
    }
    resource function onBinary(http:WebSocketCaller caller, byte[] b) {
        io:println("\nNew binary message received");
        io:print("UTF-8 decoded binary message: ");
        io:println(b);
        var err = caller->pushBinary(b);
        if (err is http:WebSocketError) {
            log:printError("Error occurred when sending binary", err);
        }
    }
    resource function onPing(http:WebSocketCaller caller, byte[] data) {
        var err = caller->pong(data);
        if (err is http:WebSocketError) {
            log:printError("Error occurred when closing the connection", err);
        }
    }
    resource function onPong(http:WebSocketCaller caller, byte[] data) {
        io:println("Pong received");
    }
    resource function onIdleTimeout(http:WebSocketCaller caller) {
        io:println("\nReached idle timeout");
        io:println("Closing connection " + caller.getConnectionId());
        var err = caller->close(statusCode = 1001, reason =
                                    "Connection timeout");
        if (err is http:WebSocketError) {
            log:printError("Error occurred when closing the connection", err);
        }
    }
    resource function onError(http:WebSocketCaller caller, error err) {
        log:printError("Error occurred ", err);
    }
    resource function onClose(http:WebSocketCaller caller, int statusCode,
                                string reason) {

        wsClients= wsClients.filter(item=> item !== caller);
        io:println(string `Client left with ${statusCode} because ${reason}`);
    }
}

public function getWebSocketClients() returns WsUser[] {
    return wsUsers;
}