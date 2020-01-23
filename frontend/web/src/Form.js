import React from "react"
import BMap from './Map'
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import axios from 'axios'; 
import { polygon } from 'leaflet';
import * as turf from '@turf/turf'

var yala = [[6.279629, 81.424341], [6.668179, 81.771591], [6.713189,81.716037], [6.610547,81.587634], [6.607818, 81.529269], [6.618731, 81.510730], [6.607136, 81.494937], [6.702619, 81.354861], [6.624188, 81.266284], [6.536876, 81.263538], [6.510270, 81.135135], [6.396327, 81.145993], [6.351289, 81.199551], [6.386092, 81.273022], [6.461831, 81.276455], [6.447503, 81.335507], [6.322626, 81.383572], [6.309318, 81.374131], [6.300446, 81.372929], [6.277241, 81.405201],[6.279629, 81.424341]] 
var polyyala = turf.polygon([yala]);
var msg="";

class Form extends React.Component {
  constructor(props){
    super(props)
  this.state = {
    cats: [{lat:"", long:""}],
    points: [[10.022443, 80.260258],[5.815325, 80.692459]],
    coords: this.props.coords
  }
  axios.get('http://localhost:9090/add/createPoly', this.state)
            .then(function(response){
                //console.log(yala)
                //console.log("holla")
                yala = response.data
                //console.log(yala);
            })
  
}

  
handleChange = (e) => {
    if (["lat", "long"].includes(e.target.className) ) {
      let cats = [...this.state.cats]
      cats[e.target.dataset.id][e.target.className] = e.target.value.toUpperCase()
      this.setState({ cats }, () => console.log(this.state.cats))
     
      
       
    } else {
      this.setState({ [e.target.lat]: e.target.value.toUpperCase() })
    }
     
  }
addCat = (e) => {
    this.setState((prevState) => ({
      cats: [...prevState.cats, {lat:"", long:""}],
    }));
    var temp =[]
  if (this.state.cats.length>=3){
    for (let index = 0; index < this.state.cats.length; index++) { 
      if(this.state.cats[index].lat!=="" || this.state.cats[index].long !==""){
       // console.log(this.state.cats[index].lat, this.state.cats[index].long)
        temp.push([this.state.cats[index].lat, this.state.cats[index].long] )
      }
    }
    if (temp.length > 2){
      //console.log("temp", temp)
      this.setState({points:temp})
      
    }
  }
}

draw = (e) => { 
  var temp =[]
  if (this.state.cats.length>=3){


    for (let index = 0; index < this.state.cats.length; index++) { 
      if(this.state.cats[index].lat!=="" || this.state.cats[index].long !==""){
       // console.log(this.state.cats[index].lat, this.state.cats[index].long)
        temp.push([this.state.cats[index].lat, this.state.cats[index].long] )
      }
    }
    if (temp.length > 2){
      //console.log("temp", temp)
      this.setState({points:temp})
      
    }
  console.log("OKK")
}
if(temp.length>2){
  var p = temp
  p.push(temp[0])
  console.log(temp, p)
  //console.log("intersect", temp)

  var intersection = turf.intersect(polyyala, turf.polygon([p]))
  if(intersection !==null){
    msg="Not Available: Area given intersects with Protected Area"
    console.log(msg)
  }
  else{
    console.log("available")
    msg = "Available"
  }
  console.log(intersection)
}

}

handleSubmit = (e) => { 
  
  console.log(yala.data)
  var l = document.getElementById('landtype').value
  var t = document.getElementById('timeframe').value
  var d = document.getElementById('desc').value
  var x = {points: this.state.points, landtype:l, timeframe:t, description:d}
  

  // const link = ""
  // axios({
  //   method: 'post',
  //   url: link,
  //   data: x
  // });
  //aconsole.log(document.getElementById('landtype').value);
  e.preventDefault() 
}
render() {
  
    let {cats} = this.state
    let error_msg;
    let poly;
    if(this.state.points.length<3){
      error_msg = "\nNeed at least 3 points"
    }
    else{
      poly = <Polygon  positions = {this.state.points}/>
      error_msg=""
    }

    return (
      <div>
        
        
        <Map
          style={{ height: "480px", width: "60%" }}

          //zoomed to center on given coords
          bounds = {this.state.points}>
          <TileLayer url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"/>

          <Polygon //red polygons for national parks 
            positions = {yala}
            color = 'red'
          />
          {poly}}
        </Map>
      
      
      <form id = 'form' onSubmit={this.handleSubmit} onChange={this.handleChange} >
        
        <button type = 'button' onClick={this.addCat.bind(this)}>Add new point</button>
        {
          cats.map((val, idx)=> {
            let catId = `cat-${idx}`, ageId = `age-${idx}`
            return (
              <div key={idx}>
                <label htmlFor={catId}>Lat</label>
                <input
                  type="text"
                  name={catId}
                  data-id={idx}
                  id={catId}
                  value={cats[idx].lat} 
                  className="lat"
                />
                <label htmlFor={ageId}>Long</label>
                <input
                  type="text"
                  name={ageId}
                  data-id={idx}
                  id={ageId}
                  value={cats[idx].long} 
                  className="long"
                />
              </div> 
            )
          })  
        }
          <div>
              <br></br>
              {error_msg}
              <br></br>
              {msg}
          </div>
        <button type = 'button' onClick={this.draw.bind(this)}>Check Availability</button>
        <br></br>
        <label>
          <br></br>
            Land Type: 
            <select id ="landtype">
              <option value="Plantation">Plantation</option>
              <option value="Forestation">Forestation</option>
              <option selected value="Deforestation">Deforestation</option>
              <option value="Hotel">Hotel</option>
            </select>
        </label>

        <br></br>
        <label>
            Timeframe: 
            <input
            Timeframe=""
            type="text"
            value={this.state.fullname}
            onChange={this.handleInputChange} 
            id = 'timeframe'/>
        </label>

        <br></br>
        <label>
            Description: 
            <input
            Timeframe=""
            type="text"
            value={this.state.fullname}
            onChange={this.handleInputChange} 
            id = 'desc'/>
        </label>
        <br></br>
        <label>Attach Files: </label>
        <input type="file" />
        <br></br>
        <input type="submit" value="Submit Form" />
      </form>
      
      </div>
      
    )
  }
}
export default Form
