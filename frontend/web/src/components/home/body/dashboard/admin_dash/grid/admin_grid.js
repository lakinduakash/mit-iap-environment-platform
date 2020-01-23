import React from "react";
import "./admin_grid.css";
import { useHistory } from "react-router-dom";
import { Button } from "@material-ui/core";

const Admin_grid = () => {
  let history = useHistory();
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
                <Button
                  type="button"
                  onClick={() => {
                    history.push("/admin-dash/request");
                    console.log("any");
                  }}
                >
                  View
                </Button>
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
};
export default Admin_grid;
