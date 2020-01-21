import React from "react";
import ReactDataGrid from "react-data-grid";

const columns = [
  { key: "id", name: "Issue ID" },
  { key: "title", name: "Title" },
  { key: "description", name: "Description" },
  { key: "depts", name: "Departments" },
  { key: "status", name: "status" },
  { key: "options", name: "options" }
];
const rows = [
  {
    id: 1,
    title: "Title 1",
    description: "first issue",
    depts: "<put checkboxes here>",
    status: "in progress",
    options: "<save/cancel button>"
  }
];
const rowGetter = rowNumber => rows[rowNumber];

class AdminIssues extends React.Component {
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

export default AdminIssues;
