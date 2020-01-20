import React, { Fragment } from "react";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import Home from "../home/home";
import AdminIssues from "./admin_issues";

function Admin() {
  return (
    <Fragment>
      <br />
      <br />
      Hello Admin!
      <AdminIssues />
    </Fragment>
  );
}

export default Admin;
