import React from "react";
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import axios from "axios";
import { polygon } from "leaflet";
import * as turf from "@turf/turf";

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
  [6.277241, 81.405201],
  [6.279629, 81.424341]
];
var polyyala = turf.polygon([yala]);
var msg = "";

class LandRequestForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      cats: [{ lat: "", long: "" }],
      points: [
        [10.022443, 80.260258],
        [5.815325, 80.692459]
      ],
      coords: this.props.coords
    };
    axios
      .get("http://localhost:9090/add/createPoly", this.state)
      .then(function(response) {
        //console.log(yala)
        //console.log("holla")
        yala = response.data;
        //console.log(yala);
      });
  }

  handleChange = e => {
    if (["lat", "long"].includes(e.target.className)) {
      let cats = [...this.state.cats];
      cats[e.target.dataset.id][
        e.target.className
      ] = e.target.value.toUpperCase();
      this.setState({ cats }, () => console.log(this.state.cats));
    } else {
      this.setState({ [e.target.lat]: e.target.value.toUpperCase() });
    }
  };
  addCat = e => {
    this.setState(prevState => ({
      cats: [...prevState.cats, { lat: "", long: "" }]
    }));
    var temp = [];
    if (this.state.cats.length >= 3) {
      for (let index = 0; index < this.state.cats.length; index++) {
        if (
          this.state.cats[index].lat !== "" ||
          this.state.cats[index].long !== ""
        ) {
          // console.log(this.state.cats[index].lat, this.state.cats[index].long)
          temp.push([this.state.cats[index].lat, this.state.cats[index].long]);
        }
      }
      if (temp.length > 2) {
        //console.log("temp", temp)
        this.setState({ points: temp });
      }
    }
  };

  draw = e => {
    var temp = [];
    if (this.state.cats.length >= 3) {
      for (let index = 0; index < this.state.cats.length; index++) {
        if (
          this.state.cats[index].lat !== "" ||
          this.state.cats[index].long !== ""
        ) {
          // console.log(this.state.cats[index].lat, this.state.cats[index].long)
          temp.push([this.state.cats[index].lat, this.state.cats[index].long]);
        }
      }
      if (temp.length > 2) {
        //console.log("temp", temp)
        this.setState({ points: temp });
      }
      console.log("OK");
    }
    if (temp.length > 2) {
      var p = temp;
      p.push(temp[0]);
      console.log(temp, p);
      //console.log("intersect", temp)

      var intersection = turf.intersect(polyyala, turf.polygon([p]));
      if (intersection !== null) {
        msg = "Not Available: Area given intersects with Protected Area";
        console.log(msg);
      } else {
        console.log("available");
        msg = "Available";
      }
      console.log(intersection);
    }
  };

  handleSubmit = e => {
    console.log(yala.data);
    var l = document.getElementById("landtype").value;
    var t = document.getElementById("timeframe").value;
    var d = document.getElementById("desc").value;
    var x = { points: this.state.points, timeframe: t, description: d };
    var ret = { title: l, body: x };
    const link = "http://localhost:9080/user-services/post-request/yashod";
    axios({
      method: "post",
      url: link,
      data: ret
    });

    // const link = ""
    // axios({
    //   method: 'post',
    //   url: link,
    //   data: x
    // });
    //aconsole.log(document.getElementById('landtype').value);
    e.preventDefault();
    this.props.history.push("/user-dash");
  };
  render() {
    let { cats } = this.state;
    let error_msg;
    let poly;
    if (this.state.points.length < 3) {
      error_msg = "Add at least 3 points and click on check availability";
    } else {
      poly = <Polygon positions={this.state.points} />;
      error_msg = "";
    }

    return (
      <div className="form-group">
        <form
          id="form"
          onSubmit={this.handleSubmit}
          onChange={this.handleChange}
        >
          <div className="row">
            <div
              className="col-sm-6 p-5"
              style={{ marginTop: "15px", borderRight: "2px solid #CCC" }}
            >
              <Map
                style={{ height: "480px", width: "100%", marginBottom: "15px" }}
                //zoomed to center on given coords
                bounds={this.state.points}
              >
                <TileLayer url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                <Polygon //red polygons for national parks
                  positions={yala}
                  color="red"
                />
                {poly}}
              </Map>
              <h3>
                Please enter the exact co-ordinates (in clockwise order) for the
                land area you wish to request
              </h3>
              <br></br>
              {cats.map((val, idx) => {
                let catId = `cat-${idx}`,
                  ageId = `age-${idx}`;
                return (
                  <div
                    key={idx}
                    className="row"
                    style={{ marginBottom: "20px" }}
                  >
                    <div className="col-sm-4">
                      <label htmlFor={catId}>Latitude </label>
                      <input
                        type="text"
                        name={catId}
                        data-id={idx}
                        id={catId}
                        value={cats[idx].lat}
                        className="lat"
                        style={{
                          height: "calc(1.5em + .75rem + 2px)",
                          padding: ".375rem .75rem",
                          fontSize: "1rem",
                          fontWeight: "400",
                          lineHeight: "1.5",
                          color: "#495057",
                          backgroundColor: "#fff",
                          backgroundClip: "padding-box",
                          border: "1px solid #ced4da",
                          borderRadius: ".25rem",
                          transition:
                            "border-color .15s ease-in-out,box-shadow .15s ease-in-out",
                          marginLeft: "10px"
                        }}
                      />
                    </div>
                    <div className="col-sm-4">
                      <label htmlFor={ageId}>Longitude </label>
                      <input
                        type="text"
                        name={ageId}
                        data-id={idx}
                        id={ageId}
                        value={cats[idx].long}
                        className="long"
                        style={{
                          height: "calc(1.5em + .75rem + 2px)",
                          padding: ".375rem .75rem",
                          fontSize: "1rem",
                          fontWeight: "400",
                          lineHeight: "1.5",
                          color: "#495057",
                          backgroundColor: "#fff",
                          backgroundClip: "padding-box",
                          border: "1px solid #ced4da",
                          borderRadius: ".25rem",
                          transition:
                            "border-color .15s ease-in-out,box-shadow .15s ease-in-out",
                          marginLeft: "10px"
                        }}
                      />
                    </div>
                  </div>
                );
              })}
              <div className="col-sm-4">
                <button
                  type="button"
                  onClick={this.addCat.bind(this)}
                  className="btn btn-primary"
                  style={{ width: "100%" }}
                >
                  Add new point
                </button>
              </div>
              <br></br>
              <div className="row">
                <div className="col-sm-3">
                  <br></br>
                  {error_msg}
                  <span
                    style={{
                      color: "#28a745",
                      fontSize: "20px",
                      paddingTop: "10px"
                    }}
                  >
                    {msg}
                  </span>
                </div>
                <div className="col-sm-9">
                  <br />
                  <button
                    type="button"
                    onClick={this.draw.bind(this)}
                    class="btn btn-success"
                    style={{ width: "100%" }}
                  >
                    Check Availability
                  </button>
                </div>
              </div>
            </div>

            <div className="col-sm-6 p-5" style={{ fontSize: "20px" }}>
              <br></br>
              <h1 style={{ fontSize: "40px", marginBottom: "50px" }}>
                Land Request Form
              </h1>
              <div className="form-group row">
                <div className="col-sm-2">
                  <label>
                    <br></br>
                    Land Type:
                  </label>
                </div>
                <div className="col-sm-8" style={{ marginTop: "12px" }}>
                  <select className="form-control" id="landtype">
                    <option value="Plantation">Plantation</option>
                    <option value="Forestation">Forestation</option>
                    <option selected value="Deforestation">
                      Deforestation
                    </option>
                    <option value="Hotel">Hotel</option>
                  </select>
                </div>
              </div>
              <br></br>

              <div className="form-group row">
                <div className="col-sm-2">
                  <label>
                    <br></br>
                    Description:
                  </label>
                </div>
                <div className="col-sm-8" style={{ marginTop: "12px" }}>
                  <input
                    Timeframe=""
                    type="text"
                    value={this.state.fullname}
                    onChange={this.handleInputChange}
                    id="desc"
                    className="form-control"
                  />
                </div>
              </div>
              <br></br>

              <div className="form-group row">
                <div className="col-sm-2">
                  <label>
                    <br></br>
                    Timeframe:
                  </label>
                </div>
                <div className="col-sm-8" style={{ marginTop: "12px" }}>
                  <input
                    Timeframe=""
                    type="text"
                    value={this.state.fullname}
                    onChange={this.handleInputChange}
                    id="timeframe"
                    className="form-control"
                  />
                </div>
              </div>
              <br></br>

              <div className="form-group row" style={{ marginTop: "15px" }}>
                <div className="col-sm-2">
                  <label>Attach Files: </label>
                </div>
                <div className="col-sm-8" style={{ fontSize: "15px" }}>
                  <input type="file" className="form-control-file" />
                </div>
              </div>
              <br></br>

              <div className="form-group row" style={{ marginTop: "125px" }}>
                <div className="col-sm-5 col-xs-12">
                  <input
                    type="submit"
                    id="draft"
                    value="Save Draft"
                    className="btn btn-secondary float-right"
                    style={{ width: "80%" }}
                  />
                </div>
                <div className="col-sm-6 col-xs-12">
                  <input
                    type="submit"
                    id="submit"
                    value="Submit Form"
                    className="btn btn-success"
                    style={{ width: "65%" }}
                  />
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
    );
  }
}
export default LandRequestForm;
