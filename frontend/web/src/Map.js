import React, { Component } from 'react';
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";
import "leaflet/dist/leaflet.css";

class BMap extends Component {
    constructor(props) {
        super(props); 
        this.state = {
            coords: this.props.coords 
        }
    }
  render() {
    return (
      <div>
        <Map
          style={{ height: "480px", width: "50%" }}
          zoom={6.9}
          center={[7.99, 80.505]}>
          <TileLayer url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"/>
          <CircleMarker
            center={[6.9271, 79.8612]}
          />
          
          <Polygon
            positions = {this.state.coords}
          />
        </Map>
      </div>
    );
  }
}

export default BMap;