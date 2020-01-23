import React, { Fragment } from "react";
import "./App.css";
import Home from "./components/home/home";
import RequestProvider from "./components/utility/contexts/requestContext";

function App() {
  return (
    <Fragment>
      <RequestProvider>
        <Home />
      </RequestProvider>
    </Fragment>
  );
}

export default App;
