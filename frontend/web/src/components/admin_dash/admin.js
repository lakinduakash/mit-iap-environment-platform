import React, { Fragment } from "react";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import Home from "../home/home";

function Admin() {
  return (
    <Fragment>
        <Header/>
            <br/>
            <br/>
            Hello Admin!
        <Footer/>
    </Fragment>
  );
}

export default Admin;