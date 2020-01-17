import React, { Fragment } from "react";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import Home from "../home/home";

function User() {
  return (
    <Fragment>
        <Header/>
            <br/>
            <br/>
            Hello User!
        <Footer/>
    </Fragment>
  );
}

export default User;