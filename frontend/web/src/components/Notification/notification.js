import React, { Component } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

class Notification extends Component {

  // instance of websocket connection as a class property
  ws = new WebSocket('ws://localhost:9095')
  msg = "";

  componentDidMount() {
      this.ws.onopen = () => {
      // on connecting, do nothing but log it to the console
      console.log('connected to websocket server')
      }

      this.ws.onmessage = evt => {
      // listen to data sent from the websocket server
      const message = evt.data
      msg = message
      this.setState({dataFromServer: message})
      alert('Notification received : ' + message);
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
      < Notification_holder value = {this.msg} />
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
const useStyles = makeStyles({
  card: {
    minWidth: 275,
  },
  bullet: {
    display: 'inline-block',
    margin: '0 2px',
    transform: 'scale(0.8)',
  },
  title: {
    fontSize: 14,
  },
  pos: {
    marginBottom: 12,
  },
});

class Notification_holder extends Component{

  constructor(props) {
    super(props);
    this.state = {value: ''};
  }

    render() {
      return (
        <Card className={classes.card}>
          <CardContent>
            <Typography className={classes.title} color="textSecondary" gutterBottom>
              
            </Typography>
            <Typography variant="h5" component="h2">
              Notification
            </Typography>
            <Typography className={classes.pos} color="textSecondary">
            </Typography>
            <Typography variant="body2" component="p">
              {this.props.value}
              <br />
            </Typography>
          </CardContent>
          <CardActions>
            <Button size="small">Learn More</Button>
          </CardActions>
        </Card>
      );
    }
}