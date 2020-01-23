import React, { Fragment, useContext, useEffect, useState } from "react";
import { AdminRequestContext } from "../../../../../utility/contexts/adminRequestContext";
import "./request_info.css";
import { useHistory } from "react-router-dom";
import axios from "axios";
import { Button, Comment, Form, Header } from "semantic-ui-react";
import Avatar from "../../../../../../asserts/images/avatar.png";
import { Map, CircleMarker, TileLayer, Polygon } from "react-leaflet";

const AdminView = () => {
  const [
    id,
    title,
    status,
    body,
    owner,
    tags,
    assignees,
    ,
    ,
    setStatus
  ] = useContext(AdminRequestContext);
  const [loading] = useState(null);
  let history = useHistory();
  const [data, setData] = useState(null);
  const [comments, setComments] = useState(null);
  const [reply, setReply] = useState("");
  const [labels, setLabels] = useState(null);
  const [state, setState] = useState();
  const [newState, setNewState] = useState("");
  const pending = "Pending";

  const handleSubmit = event => {
    axios
      .post("http://0.0.0.0:9070/admin-services/post-comment/" + id, {
        body: reply
      })
      .then(response => {
        console.log(response.data);
        setReply("");
        getComments();
      })
      .catch();
  };

  const getLabels = () => {
    axios
      .get("http://0.0.0.0:9070/admin-services/get-all-labels")
      .then(response => {
        console.log(response.data);
        setLabels(response.data);
      })
      .catch();
  };

  const removeLabel = () => {
    axios
      .delete(
        "http://0.0.0.0:9070/admin-services/remove-label/" + id + "/" + status
      )
      .then(response => {
        console.log(response);
      })
      .catch();
  };

  const getComments = () => {
    axios
      .get("http://0.0.0.0:9070/admin-services/get-comments/" + id)
      .then(response => {
        setComments(response.data);
        setData(JSON.parse(body));
        console.log(response.data);
      })
      .catch();
  };

  const assignLabel = () => {
    axios
      .post("http://0.0.0.0:9070/admin-services/assign-label/" + id, {
        labelNames: [state]
      })
      .then(response => {
        console.log(response);
      })
      .catch();
  };

  const changeState = () => {
    if (status != "") {
      removeLabel();
    }
    if (state != undefined) {
      assignLabel();
      setStatus(state);
    }
  };

  useEffect(() => {
    getComments();
    getLabels();
  }, [loading, id]);

  const createNewLabel = () => {};

  return (
    <Fragment>
      <br />
      <button
        className="btn btn-info request-button"
        onClick={() => {
          history.goBack();
        }}
      >
        Back
      </button>
      <h2>{newState}</h2>
      <div className="row request-div">
        <div className="col-sm-8 ">
          <div className="card">
            <div className="card-header">
              <h1> {title}</h1>
            </div>
            <div className="card-body">
              <div className="row ">
                <div className="col-sm-10">
                  <h3>
                    Status of the Request: {status != "" ? status : pending}
                  </h3>
                </div>
                <div className="col-sm-2 ">
                  <button
                    type="button"
                    class="btn btn-info"
                    data-toggle="modal"
                    data-target="#myModal"
                  >
                    Change State
                  </button>

                  <div class="modal" id="myModal">
                    <div class="modal-dialog modal-dialog-centered">
                      <div class="modal-content">
                        <div class="modal-body">
                          <button
                            type="button"
                            class="close"
                            data-dismiss="modal"
                          >
                            &times;
                          </button>
                          <h3>Change State</h3>
                          <hr />
                          <div class="form-group">
                            <label for="sel1">Select list:</label>
                            <select
                              class="form-control"
                              value={state}
                              onChange={event => setState(event.target.value)}
                            >
                              {labels != null
                                ? labels.map(label => (
                                    <option value={label.labelName}>
                                      {label.labelName}
                                    </option>
                                  ))
                                : null}
                            </select>
                            <br />
                            <button
                              class="btn btn-primary"
                              data-toggle="modal"
                              data-target="#myModal2"
                            >
                              New Status
                            </button>
                            {"  "}
                            <button
                              onClick={() => changeState()}
                              type="submit"
                              class="btn btn-primary"
                              data-dismiss="modal"
                            >
                              Submit
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="modal fade" id="myModal2">
                    <div class="modal-dialog modal-dialog-centered">
                      <div class="modal-content">
                        <div class="modal-body">
                          <button
                            type="button"
                            class="close"
                            data-dismiss="modal"
                          >
                            &times;
                          </button>
                          <form class="was-validated">
                            <div class="form-group">
                              <label for="uname">State Name:</label>
                              <input
                                type="text"
                                class="form-control"
                                id="uname"
                                placeholder="Enter username"
                                name="uname"
                                value={newState}
                                onChange={event => {
                                  setNewState(event.target.value);
                                }}
                                required
                              />
                              <div class="valid-feedback">Valid.</div>
                              <div class="invalid-feedback">
                                Please fill out this field.
                              </div>
                            </div>

                            <button
                              onClick={() => {
                                createNewLabel();
                              }}
                              type="submit"
                              class="btn btn-primary"
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
              <hr />

              {data != null ? (
                <div>
                  <h3>Description : {data.description}</h3>
                  <h3>Duration : {data.timeframe}</h3>
                  <h3>Place</h3>
                  <Map
                    style={{ height: "480px", width: "100%" }}
                    //zoomed to center on given coords
                    bounds={data.points}
                  >
                    <TileLayer url="http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                    <Polygon //blue polygon for given coords
                      positions={data.points}
                    />
                  </Map>
                </div>
              ) : (
                <p>Please wait</p>
              )}
            </div>
          </div>
        </div>
        <div className="col-sm-4 ">
          <Comment.Group size="large">
            <Header as="h3" dividing>
              Process of the Request
            </Header>
            {comments != null ? (
              comments.map(comment => (
                <Comment key={comment.commentId}>
                  <Comment.Avatar
                    src={Avatar}
                    alt="WSO2"
                    width="40"
                    height="40"
                  />
                  <Comment.Content>
                    <Comment.Author as="a">{comment.user}</Comment.Author>
                    <Comment.Text>{comment.comment}</Comment.Text>
                    <Comment.Actions>
                      <Comment.Action>Reply</Comment.Action>
                    </Comment.Actions>
                  </Comment.Content>
                </Comment>
              ))
            ) : (
              <h3>no</h3>
            )}
            <br />
            <Form>
              <Form.Field>
                <input
                  type="text"
                  value={reply}
                  onChange={event => setReply(event.target.value)}
                />
              </Form.Field>
              <Button
                content="Add Reply"
                labelPosition="left"
                icon="edit"
                primary
                onClick={() => handleSubmit()}
              />
            </Form>
          </Comment.Group>
        </div>
      </div>
    </Fragment>
  );
};

export default AdminView;
