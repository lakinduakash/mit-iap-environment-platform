import React, { Fragment } from "react";
import {
  Route,
  BrowserRouter as Router,
  Switch,
  Redirect
} from "react-router-dom";

import PrimarySearchAppBar from "./header/user_header/user_header";
import Footer from "./footer/footer";
import LoginForm from "../home/body/login/login";
import SignupForm from "../home/body/signup/signup";
import User from "./body/dashboard/user_dash/user_dash";
import Admin from "./body/dashboard/admin_dash/admin_dash";
import Notification from "../Notification/notification";
import Request from "./body/dashboard/user_dash/request_info/request_info";
import LandRequestForm from "../LandRequestForm/land-request-form"
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
            <Route exact path="/user-dash/request" component={Request} />
            <Route exact path="/new-issue" component={LandRequestForm} />
            <Redirect exact from="" to="/login" />
          </Switch>
        </div>
        <Footer />
      </Fragment>
    </Router>
  );
};

export default Home;
