import React, { Component } from "react";
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";
import "leaflet/dist/leaflet.css";

var yala = [
  [6.279629, 81.424341],
  [6.668179, 81.771591],
  [6.713189, 81.716037],
  [6.610547, 81.587634],
  [6.607818, 81.529269],
  [6.618731, 81.51073],
  [6.607136, 81.494937],
  [6.702619, 81.354861],
  [6.624188, 81.266284],
  [6.536876, 81.263538],
  [6.51027, 81.135135],
  [6.396327, 81.145993],
  [6.351289, 81.199551],
  [6.386092, 81.273022],
  [6.461831, 81.276455],
  [6.447503, 81.335507],
  [6.322626, 81.383572],
  [6.309318, 81.374131],
  [6.300446, 81.372929],
  [6.277241, 81.405201]
];

class BMap extends Component {
  constructor(props) {
    super(props);
    this.state = {
      coords: this.props.coords
    };
  }
  render() {
    return (
      <div>
        <Map
          style={{ height: "480px", width: "60%" }}
          //zoomed to center on given coords
          bounds={[this.state.coords]}
        >
          <TileLayer url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />

          <Polygon //blue polygon for given coords
            positions={this.state.coords}
          />
        </Map>
      </div>
    );
  }
}

export default BMap;
