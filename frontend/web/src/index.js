import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min";

import { Route, BrowserRouter as Router, Switch } from "react-router-dom";
//import Users from "./users";
//import Contact from "./contact";
//import Notfound from "./notfound";
import Header from "./Components/Header/header";
import Footer from "./Components/Footer/footer";
import LoginForm from "./Components/login-signup/LoginForm";
import SignupForm from "./Components/login-signup/SignupForm";
import 'semantic-ui-css/semantic.min.css';

//ReactDOM.render(<App />, document.getElementById('root'));

const routing = (
  <Router>
    <div>
      <Header />
      <hr />
      <Switch>
        <Route exact path="/" component={App} />
        <Route exact path="/login" component={LoginForm} />
        <Route exact path="/signup" component={SignupForm} />


        {/* <Route path="/users" component={Users} />
        <Route path="/contact" component={Contact} />
        <Route component={Notfound} /> */}
      </Switch>
      <Footer />
    </div>
  </Router>
);

ReactDOM.render(routing, document.getElementById("root"));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
