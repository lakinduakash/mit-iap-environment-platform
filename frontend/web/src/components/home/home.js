import React, { Fragment } from "react";
// import ReactDOM from "./node_modules/react-dom";
// import "./index.css";
import App from "../../App";
// import * as serviceWorker from "./serviceWorker";
// import "./node_modules/bootstrap/dist/css/bootstrap.min.css";
// import "./node_modules/bootstrap/dist/js/bootstrap.bundle.min";

import {
  Route,
  BrowserRouter as Router,
  Switch,
  Redirect
} from "react-router-dom";
import Header from "./Header/header";
import Footer from "./Footer/footer";
import LoginForm from "./login-signup/LoginForm";
import SignupForm from "./login-signup/SignupForm";
import User from "../user_dash/user";
import Admin from "../admin_dash/admin";

// import 'semantic-ui-css/semantic.min.css';
import "./home.css";

const Home = () => {
  return (
    <Router>
      <Fragment>
        <Header />
        <div className="body">
          <Switch>
            {/* <Route exact path="/" component={App} /> */}
            <Route exact path="/login" component={LoginForm} />
            <Route exact path="/signup" component={SignupForm} />
            <Route exact path="/user-dash" component={User} />
            <Route exact path="/admin-dash" component={Admin} />
            <Redirect exact from="" to="/login" />
          </Switch>
        </div>
        <Footer />
      </Fragment>
    </Router>
  );
};

export default Home;
