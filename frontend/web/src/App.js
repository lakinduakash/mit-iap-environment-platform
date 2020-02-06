import React, { Fragment } from "react";
import "./App.css";
import Home from "./components/home/home";
import RequestProvider from "./components/utility/contexts/request_context";
import AdminRequestProvider from "./components/utility/contexts/admin_request_context";
import AuthorityRequestProvider from "./components/utility/contexts/authority_request_context";

function App() {
  return (
    <Fragment>
      <RequestProvider>
        <AdminRequestProvider>
          <AuthorityRequestProvider>
            <Home />
          </AuthorityRequestProvider>
        </AdminRequestProvider>
      </RequestProvider>
    </Fragment>
  );
}

export default App;
