import React from "react";
import ReactDataGrid from "react-data-grid";

const columns = [
  { key: "id", name: "Issue ID" },
  { key: "title", name: "Title" },
  { key: "description", name: "Description" },
  { key: "status", name: "Status" }
];
const rows = [
  { id: 1, title: "Title 1", description: "first issue", status: "in progress" }
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
