import React from "react";
import { NavLink } from "react-router-dom";

function Header() {
  return (
    <div align="right">
    Logged in as: user@user.com
    <nav>
      <NavLink exact activeClassName="active" to="/">
        Home
      </NavLink>
      {/* <NavLink activeClassName="active" to="/users">
        Users
      </NavLink>
      <NavLink activeClassName="active" to="/contact">
        Contact
      </NavLink> */}
      
    </nav>
  </div>

    
    
  );
}
export default Header;