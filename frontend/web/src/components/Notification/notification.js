import React, { Component } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Alert from '@material-ui/lab/Alert';

class Notification extends Component {

  // instance of websocket connection as a class property
  ws = new WebSocket('ws://localhost:9095/notifications')
  messageList = ["Issue created", "Request pending"];

  componentDidMount() {
      this.ws.onopen = () => {
      // on connecting, do nothing but log it to the console
      console.log('connected to websocket server')
      }

      this.ws.onmessage = evt => {
      // listen to data sent from the websocket server
      const message = evt.data
      this.messageList.push(message);
      this.setState({dataFromServer: message})
      console.log(message)
      }

      this.ws.onclose = () => {
      console.log('disconnected')
      // automatically try to reconnect on connection loss

      }

  }

  render(){
    return (<div>
       <ChildComponent websocket={this.ws} />
      < Notification_holder value = {this.messageList} />
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
    marginLeft:'200px',
    marginRight:'200px'
  }
}));

function Notification_holder(notif){
  const classes = useStyles();
  let array = [];
  for(let i = 0; i < notif.value.length; i++) {
    array.push(
      <Alert className={classes.alert} variant="outlined" severity="info">
        {notif.value[i]}
        </Alert>
    );
  }

      return (
        <div className={classes.root}>
        {array}
        </div>
      );
}