import React, { useEffect } from "react";
import axios from "axios";
import { useState } from "react";

const View_request = props => {
  const [comments, setComments] = useState();
  const [loading, setLoading] = useState(false);
  return (
    <div>
      <button
        type="button"
        className="btn btn-info"
        data-toggle="modal"
        data-target="#myModal"
      >
        View
      </button>

      <div className="modal" id="myModal">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <h4 className="modal-title">{props.row.requsetTitle}</h4>
              <button type="button" className="close" data-dismiss="modal">
                &times;
              </button>
            </div>
            <div className="modal-body">Modal body..</div>

            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-danger"
                data-dismiss="modal"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default View_request;
