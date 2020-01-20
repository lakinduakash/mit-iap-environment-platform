import React, { Fragment } from "react";
import ReactDataGrid from "react-data-grid";
import {
  Grid,
  Checkbox,
  Form,
  Segment,
  Message,
  Button
} from "semantic-ui-react";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import Home from "../home/home";

const columns = [
  { key: "id", name: "Issue ID" },
  { key: "title", name: "Title" },
  { key: "description", name: "Description" },
  { key: "state", name: "State" }
];
const rows = [
  { id: 1, title: "Title 1", description: "first issue", state: "in progress" }
];
const rowGetter = rowNumber => rows[rowNumber];

class UserIssues extends React.Component {
  render() {
    return (
      <ReactDataGrid
        columns={columns}
        rowGetter={rowGetter}
        rowsCount={rows.length}
        minHeight={500}
      />
    );
  }
}

export default UserIssues;
