import React from 'react';
import {Grid, Checkbox, Form, Header, Segment, Message, Button} from 'semantic-ui-react';
import 'semantic-ui-css/semantic.min.css';

class LoginForm extends React.Component {

    
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
                                <Form.Input icon='user' iconPosition='left' placeholder='Email' name='email' />
                                <Form.Input icon='lock' iconPosition='left' placeholder='Password' name='password'/>
                                <Checkbox label='Remember password'/><br></br><br></br>
                                <Button color='teal'type='login'>Log in</Button>
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
