import React, { Component } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Alert from '@material-ui/lab/Alert';
import AlertTitle from '@material-ui/lab/AlertTitle';

class Notification extends Component {

  // instance of websocket connection as a class property
  ws = new WebSocket('ws://localhost:9095/notifications')
  messageList = [];

  componentDidMount() {
      this.ws.onopen = () => {
        // on connecting, do nothing but log it to the console
        console.log('connected to websocket server')
        try {
          this.ws.send("admin") //send data to the server
        } catch (error) {
          console.log(error) // catch error
        }
      }

      this.ws.onmessage = evt => {
        // listen to data sent from the websocket server
        const message = evt.data
        console.log(message);

        // Convert message to json
        try {
          var notificationJson = JSON.parse(message);
          console.log(notificationJson)
          this.messageList.push(notificationJson);
          this.setState({dataFromServer: message});
        } catch (error) {
          console.log(error);
        }

        this.ws.onclose = () => {
          console.log('disconnected')
          // automatically try to reconnect on connection loss
        }
    }

  }

  render(){
    return (
      <div style={{marginTop: "50px"}}>
        <Notification_holder value = {this.messageList} />
      </div>
    )
  }
}

export default Notification;

class ChildComponent extends Component {

  sendMessage=(data)=>{
      const {websocket} = this.props // websocket instance passed as props to the child component.

      try {
          websocket.send(data) //send data to the server
      } catch (error) {
          console.log(error) // catch error
      }
  }
  constructor(props) {
    super(props);
    this.state = {value: ''};

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  handleSubmit(event) {
    this.sendMessage(this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Message:
          <input type="text" value={this.state.value} onChange={this.handleChange} />
        </label>
        <input type="submit" value="Send    " />
      </form>
    );
  }
}
const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    '& > * + *': {
      marginTop: theme.spacing(2)
    }
  },
  alert: {
    marginLeft:'600px',
    marginRight:'600px'
  }
}));

function Notification_holder(notif){
  const classes = useStyles();
  let array = [];
  var alertSeverity = "";

  notif.value.forEach(element => {
    if (element.category === "Issue Created") {
      alertSeverity = "success";
    } else if (element.category === "Issue Edited") {
      alertSeverity = "info";
    } else if (element.category === "Issue Closed") {
      alertSeverity = "error"
    } else if (element.category === "Comment Created") {
      alertSeverity = "success"
    } else if (element.category === "Label Added") {
      alertSeverity = "warning"
    }
    array.push(
      <Alert className={classes.alert} severity={alertSeverity}>
        <AlertTitle>{element.category}</AlertTitle>
        {element.description}
      </Alert>
    );
    console.log(element);
  });


  return (
    <div className={classes.root}>
      {array}
    </div>
  );
}
