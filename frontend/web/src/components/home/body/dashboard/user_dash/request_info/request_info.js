import React, { Fragment, useContext, useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import { RequestContext } from "../../../../../utility/contexts/requestContext";
import "./request_info.css";
import axios from "axios";
import { Button, Comment, Form, Header } from "semantic-ui-react";
import Avatar from "../../../../../../asserts/images/avatar.png";

const Requset = () => {
  let history = useHistory();
  const [id, title, state, body] = useContext(RequestContext);
  const [loading] = useState(null);
  const [comments, setComments] = useState(null);
  const [reply, setReply] = useState("");

  const handleSubmit = event => {
    axios
      .post(
        "http://0.0.0.0:9060/user-services/post-comment/" + id + "/yashod",
        { body: reply }
      )
      .then(response => {
        console.log(response.data);
        setReply("");
        axios
          .get(
            "http://0.0.0.0:9060/user-services/get-comments/" + id + "/yashod"
          )
          .then(response => {
            setComments(response.data);
          })
          .catch();
      })
      .catch();
  };

  useEffect(() => {
    axios
      .get("http://0.0.0.0:9060/user-services/get-comments/" + id + "/yashod")
      .then(response => {
        setComments(response.data);
      })
      .catch();
  }, [loading, id]);
  return (
    <Fragment>
      <button
        className="btn btn-info request-button"
        onClick={() => {
          history.goBack();
        }}
      >
        Back
      </button>
      <div className="body-request-info">
        <h1>Title : {title}</h1>
        <hr />
        <h2>Description : {body}</h2>

        <h4>Status : {state}</h4>
        <hr />

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
    </Fragment>
  );
};

export default Requset;
