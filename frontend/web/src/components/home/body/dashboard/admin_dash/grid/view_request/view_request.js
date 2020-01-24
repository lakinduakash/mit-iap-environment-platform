import React, { useContext } from "react";
import { useHistory } from "react-router-dom";
import { AdminRequestContext } from "../../../../../../utility/contexts/adminRequestContext";

const View_request = props => {
  let history = useHistory();
  const [
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    setId,
    setTitle,
    setState,
    setBody,
    setOwner,
    setTags,
    setAssignees
  ] = useContext(AdminRequestContext);

  return (
    <div>
      <button
        type="button"
        className="btn btn-info"
        onClick={() => {
          history.push("/admin-dash/request");
          setId(props.row.requsetNumber);
          setTitle(props.row.requestTitle);
          setState(props.row.status);
          setBody(props.row.requestBody);
          setOwner(props.row.owner);
          setTags(props.row.tags);
          setAssignees(props.row.assignees);
        }}
      >
        View
      </button>
    </div>
  );
};

export default View_request;
