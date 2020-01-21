import React, { Fragment } from "react";
import Logo from "../../../asserts/images/logo-dash.png";
import "./header.css";

const Header = () => {
  return (
    // <nav>
    //   <NavLink exact activeClassName="active" to="/">
    <Fragment>
      <div className="header ">
        <img
          src={Logo}
          alt="WSO2"
          width="40"
          height="40"
          className="header-logo"
        />
        <h2 className="header-header">
          <b> Environmental Management Platform</b>
        </h2>
      </div>
    </Fragment>
    // </NavLink>
    // </nav>
  );
};
export default Header;
