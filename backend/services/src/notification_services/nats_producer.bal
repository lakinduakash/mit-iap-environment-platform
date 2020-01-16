import ballerina/nats;
import ballerina/io;

type Notification record {
    string issueCreator?;
    string receiver;
    string category;
    string description;
};

public function main() {
    nats:Connection connection = new ("nats://34.70.192.249:4222");
    nats:Producer producer = new (connection);
    string subject = "demo";
    string message = "";
    while (true) {
        message = io:readln("Enter message : ");
        nats:Error? publish = producer->publish(subject, <@untainted>message);
    }
}
