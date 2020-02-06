import React, { Fragment, useState, useEffect } from "react";
import axios from "axios";
import "./management_panel.css";
import { useHistory } from "react-router-dom";

const ManagementPanel = () => {
  const history = useHistory();
  const [newState, setNewState] = useState();
  const [collaborators, setCollaborators] = useState();
  const [labels, setLabels] = useState();
  const [loading] = useState();

  useEffect(() => {
    getLabels();
    getCollaborators();
  }, [loading]);

  const createNewLabel = () => {
    axios
      .post("http://0.0.0.0:9070/admin-services/create-label", {
        labelName: newState,
        labelDescription: "state"
      })
      .then(response => {
        console.log(response.data);
      })
      .catch();
  };

  const getCollaborators = () => {
    axios
      .get("http://0.0.0.0:9070/admin-services/get-all-collaborators")
      .then(response => {
        console.log(response.data);
        setCollaborators(response.data);
      })
      .catch();
  };

  const getLabels = () => {
    axios
      .get("http://0.0.0.0:9070/admin-services/get-all-labels")
      .then(response => {
        console.log(response.data);
        setLabels(response.data);
        history.push("/admin-dash/management-panel");
      })
      .catch();
  };

  return (
    <Fragment>
      <br />
      <div className="management-panel">
        <button
          className="btn btn-info request-button"
          onClick={() => {
            history.push("/admin-dash");
          }}
        >
          Back
        </button>
        <div className="row ">
          <div className="col-sm-6 ">
            <div className="card">
              <div className="card-header">
                Status
                <button
                  className="btn btn-info float-md-right"
                  data-toggle="modal"
                  data-target="#myModal2"
                >
                  Add Status
                </button>
              </div>
              <div className="card-body">
                <h4>List of Status</h4>
                <ul>
                  {labels !== undefined
                    ? labels.map((label, index) => (
                        <li key={index}>{label.labelName}</li>
                      ))
                    : null}
                </ul>
              </div>
            </div>
          </div>
          <div className="col-sm-6 ">
            <div className="card">
              <div className="card-header">
                Authorities{" "}
                <button className="btn btn-info float-md-right">
                  Add authority
                </button>
              </div>
              <div className="card-body">
                <h4>List of Authorities</h4>
                <ul>
                  {collaborators !== undefined
                    ? collaborators.map((collaborator, index) => (
                        <li key={index}>{collaborator.name}</li>
                      ))
                    : null}
                </ul>
              </div>
            </div>
          </div>{" "}
          <div className="modal fade" id="myModal2">
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <div className="modal-body">
                  <button type="button" className="close" data-dismiss="modal">
                    &times;
                  </button>
                  <form className="was-validated">
                    <div className="form-group">
                      <label>State Name:</label>
                      <input
                        type="text"
                        className="form-control"
                        id="uname"
                        placeholder="Enter state name"
                        name="uname"
                        value={newState}
                        onChange={event => {
                          setNewState(event.target.value);
                        }}
                        required
                      />
                      <div className="valid-feedback">Valid.</div>
                      <div className="invalid-feedback">
                        Please fill out this field.
                      </div>
                    </div>

                    <button
                      onClick={() => {
                        createNewLabel();
                      }}
                      type="button"
                      className="btn btn-primary"
                      data-dismiss="modal"
                    >
                      Submit
                    </button>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Fragment>
  );
};

export default ManagementPanel;
