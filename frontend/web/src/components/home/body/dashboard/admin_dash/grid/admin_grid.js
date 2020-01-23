import React, { useState, useEffect } from "react";
import "./admin_grid.css";
import { useHistory } from "react-router-dom";
import { Button } from "@material-ui/core";
import axios from "axios";
import View from "./view_request/view_request";

const Admin_grid = () => {
  let history = useHistory();
  const [loading] = useState(null);
  const [requests, setRequests] = useState();

  useEffect(() => {
    axios
      .get("http://0.0.0.0:9070/admin-services/get-all-requests")
      .then(function(response) {
        setRequests(response.data);
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
                      {JSON.parse(request.requestBody).timeframe != "" ? (
                        <li>
                          Duration - {JSON.parse(request.requestBody).timeframe}
                        </li>
                      ) : (
                        <p></p>
                      )}
                      {JSON.parse(request.requestBody).description != "" ? (
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
                    {request.status != "" ? (
                      <p>request.status</p>
                    ) : (
                      <p>Pending</p>
                    )}
                  </td>
                  <td>
                    <View row={requests} />
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
    <div className="admin-table">
      <Table />
    </div>
  );
};
export default Admin_grid;
