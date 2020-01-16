import ballerina/nats;
import ballerina/log;
import ballerina/io;

nats:Connection connection = new ("nats://34.70.192.249:4222");
listener nats:Listener natsListener = new (connection);

@nats:SubscriptionConfig {
    subject: "demo"
}
service natsConsumerService on natsListener {
    resource function onMessage(nats:Message message, string data) {
        io:println("Message recieved: " + data);
    }

    resource function onError(nats:Message message, nats:Error err) {
        log:printError("Something went wrong.", err);
    }
}