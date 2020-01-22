import React, { useState, useEffect } from "react";
import { makeStyles } from "@material-ui/core/styles";
import Loading from "../../../../../utility/loading/Loading";
import axios from "axios";
import ViewRequest from "./view_request/view_request";
import Comment from "./comment/comment";

import "./user_grid.css";

const useStyles = makeStyles({
  table: {
    minWidth: 650
  }
});

export default function SimpleTable() {
  const classes = useStyles();

  const [rows, setRows] = useState(null);
  const [loading, setLoading] = useState(null);

  useEffect(() => {
    axios
      .get("http://0.0.0.0:9060/user-services/get-requests/yashod")
      .then(function(response) {
        setRows(response.data);
      })
      .catch(function(error) {
        console.log(error);
      });
  }, [loading]);

  const Test = () => {
    return (
      <div>
        <table className="table table-hover table-bordered custom-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Details</th>
              <th>Status</th>
              <th>View</th>
              <th>Comment</th>
            </tr>
          </thead>
          <tbody>
            {rows.map(row => (
              <tr key={row.requestNumber}>
                <td>{row.requsetTitle}</td>
                <td>{row.requestDetails}</td>
                <td>{row.state}</td>
                <td>
                  <ViewRequest row={row} />
                </td>
                <td>
                  <Comment />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  return (
    <div className="user-table">{rows == null ? <Loading /> : <Test />}</div>
  );
}
