import React, { Fragment } from "react";

import Logo from "../../asserts/logo.jpeg";
import "./header.css";

const Header = () => {
  return (
    <Fragment>
      <div className="header ">
        <img
          src={Logo}
          alt="WSO2"
          width="60"
          height="60"
          className="header-logo"
        />
        <h2 className="header-logo">
          <b> Environmental Management Platform</b>
        </h2>
      </div>
    </Fragment>
  );
};
export default Header;
