import React, { Fragment } from "react";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import Home from "../home/home";
import UserIssues from "./user_issues";

function User() {
  return (
    <Fragment>
      <br />
      <br />
      Hello User!
      <UserIssues />
    </Fragment>
  );
}

export default User;
