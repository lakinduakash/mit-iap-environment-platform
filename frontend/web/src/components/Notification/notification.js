import React, { Component } from 'react';

class Notification extends Component {

  // instance of websocket connection as a class property
  ws = new WebSocket('wss://echo.websocket.org')

  componentDidMount() {
      this.ws.onopen = () => {
      // on connecting, do nothing but log it to the console
      console.log('connected to websocket server')
      }

      this.ws.onmessage = evt => {
      // listen to data sent from the websocket server
      const message = JSON.parse(evt.data)
      this.setState({dataFromServer: message})
      console.log(message)
      }

      this.ws.onclose = () => {
      console.log('disconnected')
      // automatically try to reconnect on connection loss

      }

  }

  render(){
      return <ChildComponent websocket={this.ws} />
  }
}

export default Notification;

class ChildComponent extends Component {

  sendMessage=()=>{
      const {websocket} = this.props // websocket instance passed as props to the child component.

      try {
          websocket.send(data) //send data to the server
      } catch (error) {
          console.log(error) // catch error
      }
  }
  render() {
      return (
          <div>
          </div>
      );
  }
}