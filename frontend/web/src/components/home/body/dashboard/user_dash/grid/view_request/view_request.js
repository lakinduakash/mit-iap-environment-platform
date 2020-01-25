import React, { useContext } from "react";
import { useHistory } from "react-router-dom";
import { RequestContext } from "../../../../../../utility/contexts/request_context";

const View_request = props => {
  let history = useHistory();
  const [, , , , setId, setTitle, setState, setBody] = useContext(
    RequestContext
  );

  return (
    <div>
      <button
        type="button"
        className="btn btn-info"
        onClick={() => {
          history.push("/user-dash/request");
          setId(props.row.requestNumber);
          setTitle(props.row.requsetTitle);
          setState(props.row.state);
          setBody(props.row.requestDetails);
        }}
      >
        View
      </button>
    </div>
  );
};

export default View_request;
