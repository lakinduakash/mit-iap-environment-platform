public function createFormattedIssue(json issue) returns json | error {

    json labelDetails = check getLabels(<json[]>issue.labels);
    json formattedIssue = {
        "issueId":check issue.id,
        "issueNumber":check issue.number,
        "labels": labelDetails,
        "issueTitle":check issue.title,
        "issueBody":check issue.body
    };
    return formattedIssue;
}

public function extractIssuesRelatedToUser(json[] listOfIssues, string userName) returns json | error {

    json[] issues = [];
    foreach json issue in listOfIssues {
        map<json> issueVal = <map<json>>issue;
        json labelDetails = check getLabels(<json[]>issueVal.labels);

        if (userNameExists(<json[]>labelDetails, userName)) {
            json issueInfo = {
                "issueId":check issueVal.id,
                "issueNumber":check issueVal.number,
                "labels": labelDetails,
                "issueTitle":check issueVal.title,
                "issueBody":check issueVal.body
            };
            issues[issues.length()] = issueInfo;
        }
    }
    return issues;
}

function userNameExists(json[] labels, string userName) returns boolean {

    foreach json label in labels {
        if (userName == (label.labelName.toString())) {
            return true;
        }
    }
    return false;
}

function getLabels(json[] labels) returns json | error {

    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelVal = <map<json>>label;
        labelDetails[labelDetails.length()] = {"labelName":check labelVal.name, "labelDescription":check labelVal.description};
    }
    return labelDetails;
}
