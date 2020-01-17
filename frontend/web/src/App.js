import React from 'react';
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import BMap from "./Map";



function App() {
    return (
      
      <BMap coords= {[['7.356076', '79.995043'],['8.210549', '80.703661'], ['6.816409', '81.527636']]} />
    
    );
}

export default App;
