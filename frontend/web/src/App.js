import React, { Fragment } from "react";
import "./App.css";
import Home from "./components/home/home";

function App() {
  return (
    <Fragment>
      <Home/>
    </Fragment>
  );
}

export default App;


// const position = [51.505, -0.09]
// const map = (
//   <Map center={position} zoom={13}>
//     <TileLayer
//       url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
//       attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
//     />
//     <Marker position={position}>
//       <Popup>A pretty CSS3 popup.<br />Easily customizable.</Popup>
//     </Marker>
//   </Map>
// )

// render(map, document.getElementById('map-container'))
// export default App;
