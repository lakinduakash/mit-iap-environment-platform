import React from "react";
// import Loading from "../../../../../utility/loading/loading";
// import axios from "axios";
// import ViewRequest from "./view_request/view_request";
// import Comment from "./comment/comment";

import "./admin_grid.css";
import { Button } from "@material-ui/core";

function SimpleTable() {
  const Table = () => {
    return (
      <div>
        <table className="table table-hover table-bordered custom-table">
          <thead>
            <tr>
              <th>Requset Number</th>
              <th>Request Title</th>
              <th>Request Description</th>
              <th>Owner</th>
              <th>Status</th>
              <th>Tags</th>
              <th>Change Tags</th>
              <th>View</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td>
                <Button>View</Button>
              </td>
            </tr>
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
}

export default SimpleTable;
