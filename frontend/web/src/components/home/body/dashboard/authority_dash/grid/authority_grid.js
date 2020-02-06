import React, { Fragment, useEffect, useState } from "react";
import axios from "axios";
import "./authority_grid.css";
import { useHistory } from "react-router-dom";
import Loading from "../../../../../utility/loading/loading";
import View from "./view_request/view_request";

const AuthorityGrid = () => {
  const history = useHistory();
  const [loading] = useState(null);
  const [requests, setRequests] = useState();

  useEffect(() => {
    axios
      .get("http://0.0.0.0:9060/authority-services/get-requests/deshankoswatte")
      .then(function(response) {
        setRequests(response.data);
        console.log(response.data);
      })
      .catch(function(error) {
        console.log(error);
      });
  }, [loading]);

  const Table = () => {
    return (
      <div>
        <table className="table table-hover table-bordered custom-table">
          <thead>
            <tr>
              <th>Request Title</th>
              <th>Request Description</th>
              <th>Owner</th>
              <th>Status</th>
              <th>View</th>
            </tr>
          </thead>
          <tbody>
            {requests != null ? (
              requests.map(request => (
                <tr key={request.requsetNumber}>
                  <td>{request.requestTitle}</td>
                  <td>
                    <ul>
                      {JSON.parse(request.requestBody).timeframe !== "" ? (
                        <li>
                          Duration - {JSON.parse(request.requestBody).timeframe}
                        </li>
                      ) : (
                        <p></p>
                      )}
                      {JSON.parse(request.requestBody).description !== "" ? (
                        <li>
                          Description -{" "}
                          {JSON.parse(request.requestBody).description}
                        </li>
                      ) : (
                        <p></p>
                      )}
                    </ul>
                  </td>
                  <td>{request.owner}</td>
                  <td>
                    {request.status !== "" ? (
                      <p>{request.status}</p>
                    ) : (
                      <p>Pending</p>
                    )}
                  </td>
                  <td>
                    <View row={request} />
                  </td>
                </tr>
              ))
            ) : (
              <tr></tr>
            )}
          </tbody>
        </table>
      </div>
    );
  };
  return (
    <Fragment>
      <div className="authority-table">
        <br />
        <br />
        {requests == null ? <Loading /> : <Table />}
      </div>
    </Fragment>
  );
};

export default AuthorityGrid;
