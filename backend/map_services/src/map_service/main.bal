  
import ballerina/http;
import ballerina/io;
import ballerinax/java.jdbc;


jdbc:Client testDB = new ({
    url: "jdbc:h2:file:./db_files/datadb",
    username: "test",
    password: "test"
});

public type Coordinate record {
    float lat;
    float long;
};

listener http:Listener listenerEndpoint = new(9090); //host 0.0.0.0:9090

service add on listenerEndpoint {

    @http:ResourceConfig {
        methods: ["GET"],
        cors:{
            allowOrigins:["*"]
        }
    }
    resource function createPoly(http:Caller caller, http:Request request) {
        var x = getCoords();
        io:println(x);
        json j = {coord:x};

        var res = caller->respond(<@untained>  x);
        
    }
}

function getCoords() returns  @tainted float[][] {
    var selectRet = testDB->select("SELECT * FROM YALA", Coordinate);
    float[][] coord = [];
    if (selectRet is table<Coordinate>) {
        int x =0;
        float[] temp=[];
        foreach var row in selectRet {
            coord[x]=[row.lat, row.long];
            x+=1;

        }
       
    }
    return(coord);
}

function handleUpdate(jdbc:UpdateResult|error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        io:println(message + " status: ", returned.updatedRowCount);
    } else {
        io:println(message + " failed: ", <string>returned.detail()?.message);
    }
}