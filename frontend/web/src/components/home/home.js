import React, { Fragment } from "react";
import {
  Route,
  BrowserRouter as Router,
  Switch,
  Redirect
} from "react-router-dom";
import Header from "../home/Header/header";
import Footer from "../home/Footer/footer";
import LoginForm from "../home/body/login/login";
import SignupForm from "../home/body/signup/signup";
import User from "../home/body/user_dash/user_dash";
import Admin from "../home/body/admin_dash/admin_dash";
import Notification from "../Notification/notification";
import "./home.css";

const Home = () => {
  return (
    <Router>
      <Fragment>
        <PrimarySearchAppBar />
        <div className="body">
          <Switch>
            {/* <Route exact path="/" component={App} /> */}
            <Route exact path="/login" component={LoginForm} />
            <Route exact path="/signup" component={SignupForm} />
            <Route exact path="/user-dash" component={User} />
            <Route exact path="/admin-dash" component={Admin} />
            <Route exact path="/notifications" component={Notification} />
            <Redirect exact from="" to="/login" />
          </Switch>
        </div>
        <Footer />
      </Fragment>
    </Router>
  );
};

export default Home;
