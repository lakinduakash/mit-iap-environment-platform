import React, { Fragment, useContext, useEffect, useState } from "react";
import "./request_info.css";
import { Grid } from "@material-ui/core";

function AdminView() {
  const Table = () => {
    return (
      <div>
        <h1>Hi</h1>

        <Grid
          columns={2}
          backgroundColor="rgb(55, 180, 0,0.32)"
          textAlign="center"
          padded
          style={{ height: "100vh" }}
          verticalAlign="middle"
        >
          <Grid.Column style={{ maxWidth: 1400 }}>
            <h5>grid 1</h5>
          </Grid.Column>

          <Grid.Column textAlign="left" style={{ maxWidth: 600 }}>
            <h5>grid 2</h5>
          </Grid.Column>
        </Grid>
      </div>
    );
  };

  return (
    <div className="admin-req">
      <Table />
    </div>
  );
}

export default AdminView;
