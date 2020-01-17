import React from 'react';
import {Grid, Checkbox, Form, Header, Segment, Message, Button} from 'semantic-ui-react';
import {Redirect} from 'react-router-dom';
import 'semantic-ui-css/semantic.min.css';
import App from '../../../App';

class LoginForm extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            email: "",
            password: "",
        };

        this.handleInputChange.bind(this);
    }

    handleInputChange(event) {
        const target = event.target;
        const name = target.name;
        const value = target.type === 'checkbox' ? target.checked : target.value;
        
        this.setState({
            [name]: value
          });
    }

    onLogin = () => {
        //if(userAuthenticated){
        //var id = document.getElementById("Email").value;
        if (this.state.email == "user"){
            //return  <Redirect  to='/' />
            this.props.history.push('/user-dash');
        } else if (this.state.email == "admin"){
            this.props.history.push('/admin-dash');
        }
     }
    
    render() {
        return (
            <Segment>
                <Grid columns={2} textAlign='center' padded style={{ height: '100vh' }} verticalAlign='middle'>
                    <Grid.Column  style={{ maxWidth: 1600 }}>
                        <Header as='h2' color='teal' textAlign='center' >
                            Environmental Management Platform  
                        </Header>
                        <Message>
                            Description
                        </Message>
                    </Grid.Column>
                    <Grid.Column textAlign='left' style={{ maxWidth: 400 }}>
                        <Header as='h2' color='teal' textAlign='center' >
                            Log in
                        </Header>
                        <Form>
                            <Segment stacked>
                                <Form.Input icon='user' iconPosition='left' placeholder='Email' name='email' onChange={this.handleInputChange} value={this.state.email} />
                                <Form.Input icon='lock' iconPosition='left' placeholder='Password' name='password' onChange={this.handleInputChange} value={this.state.password}/>
                                <Checkbox label='Remember password'/><br></br><br></br>
                                <Button color='teal'type='login' onClick={this.onLogin}>Log in</Button>
                            </Segment>
                        </Form>
                        <Message>
                            New to us? <a href ='/signup'>Sign Up</a>
                        </Message>
                    </Grid.Column>
                </Grid>

                </Segment>
                

        );
    }
}

export default LoginForm;
