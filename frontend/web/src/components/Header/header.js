import React, { Fragment } from "react";

import Logo from "../../asserts/logo.jpeg";
import "./header.css";
import { NavLink } from "react-router-dom";


const Header = () => {
  return (
    <nav>
      <NavLink exact activeClassName="active" to="/">
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
      </NavLink>
      </nav>
  );
};
export default Header;
