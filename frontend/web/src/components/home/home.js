import React, { Fragment } from "react";
// import ReactDOM from "./node_modules/react-dom";
// import "./index.css";
import App from "../../App";
// import * as serviceWorker from "./serviceWorker";
// import "./node_modules/bootstrap/dist/css/bootstrap.min.css";
// import "./node_modules/bootstrap/dist/js/bootstrap.bundle.min";

import { Route, BrowserRouter as Router, Switch } from "react-router-dom";
import Header from "./Header/header";

import Footer from "./Footer/footer";
import LoginForm from "./login-signup/LoginForm";
import SignupForm from "./login-signup/SignupForm";
// import 'semantic-ui-css/semantic.min.css';



const Home = () => {
    return (
        <Router>
            <Fragment>
                <Header/>

                <Switch>
                    <Route exact path="/" component={App} />
                    <Route exact path="/login" component={LoginForm} />
                    <Route exact path="/signup" component={SignupForm} />
                </Switch>
        
                <Footer/>
            </Fragment>
        </Router>
    );
};

export default Home;


