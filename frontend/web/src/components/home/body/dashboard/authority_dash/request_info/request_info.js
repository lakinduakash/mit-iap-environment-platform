import React, { Fragment, useContext, useState, useEffect } from "react";
import { AuthorityRequestContext } from "../../../../../utility/contexts/authority_request_context";
import { Button, Comment, Form, Header } from "semantic-ui-react";
import Avatar from "../../../../../../asserts/images/avatar.png";
import { Map, TileLayer, Polygon } from "react-leaflet";
import axios from "axios";
import { useHistory } from "react-router-dom";

const AuthorityView = () => {
  let history = useHistory();
  const [data, setData] = useState(null);
  const [loading] = useState(null);
  const [comments, setComments] = useState(null);
  const [reply, setReply] = useState("");
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
    setStatus,
    ,
    ,
    setAssignees
  ] = useContext(AuthorityRequestContext);

  const wait = ms => {
    var start = new Date().getTime();
    var end = start;
    while (end < start + ms) {
      end = new Date().getTime();
    }
  };

  useEffect(() => {
    axios
      .get("http://0.0.0.0:9060/authority-services/get-comments/" + id)
      .then(response => {
        setComments(response.data);
        setData(JSON.parse(body));
      })
      .catch();
  }, [loading, id]);

  const handleSubmit = event => {
    axios
      .post("http://0.0.0.0:9060/authority-services/post-comment/" + id, {
        body: reply
      })
      .then(response => {
        console.log(response.data);
        setReply("");
        wait(2500);
        axios
          .get("http://0.0.0.0:9060/authority-services/get-comments/" + id)
          .then(response => {
            console.log(response.data);
            setComments(response.data);
            setData(JSON.parse(body));
          })
          .catch();
      })
      .catch();
  };

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
      <div className="row request-div">
        <div className="col-sm-8 ">
          <div className="card">
            <div className="card-header">
              <h1> {title}</h1>
            </div>
            <div className="card-body">
              <h3>Owner : {owner}</h3>
              <h3>
                Status of the Request: {status !== null ? status : "Pending"}
              </h3>
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

export default AuthorityView;
