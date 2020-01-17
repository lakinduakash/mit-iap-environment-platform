import React, { Fragment } from "react";
import Footer from "./Footer/footer";
import Header from "./Header/header";
import LoginForm from "./login-signup/LoginForm";

const Home = () => {
  return (
    <Fragment>
      <Header />
      <LoginForm/>
      <Footer />
    </Fragment>
  );
};

export default Home;
