import React from 'react';
import {Grid, Form, Header, Button, Checkbox} from 'semantic-ui-react';
import 'semantic-ui-css/semantic.min.css';

class SignupForm extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            firstName: "",
            lastName: "",
            email: "",
            phoneNumber: "",
            address: "",
            password: "",
            confirmPassword: ""
        };

        this.handleInputChange.bind(this);
    }

    handleInputChange(event) {
        const target = event.target;
        const name = target.name;
        const value = target.type === 'checkbox' ? target.checked : target.value;
        this.setState({[name]: value});
    }

    render() {
        return (
            <Grid textAlign='center' style={{ height: '100vh' }} verticalAlign='middle'>
                <Grid.Column textAlign='left' style={{ maxWidth: 450 }}>
                <Header as='h2' color='teal' textAlign='center' >
                    Environmental Management Platform User Information
                </Header>
                <br></br>
                <Form >
                    <Form.Field>
                        <label>First Name</label>

                        <input placeholder='First Name' name ='firstName' onChange={this.handleInputChange} value={this.state.firstName}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Last Name</label>
                        <input placeholder='Last Name' name ='lastName' onChange={this.handleInputChange} value={this.state.lastName}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Email</label>
                        <input placeholder='Email' name ='email' onChange={this.handleInputChange} value={this.state.email}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Phone Number</label>
                        <input placeholder='Phone Number' name ='phoneNumber' onChange={this.handleInputChange} value={this.state.phoneNumber}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Address</label>
                        <input placeholder='Address' name ='address' onChange={this.handleInputChange} value={this.state.address}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Password</label>
                        <input placeholder='Password' name ='password' onChange={this.handleInputChange} value={this.state.password}/>
                    </Form.Field>
                    <Form.Field>
                        <label>Confirm Password</label>
                        <input placeholder='Confirm Password' name ='confirmPassword' onChange={this.handleInputChange} value={this.state.confirmPassword}/>
                    </Form.Field>
                    <Checkbox label='I agree to the Terms and Conditions' /><br></br><br></br>
                    <Button type='signup' color='teal'>Sign Up</Button>

                </Form>
                </Grid.Column>
            </Grid>
            
        );
    }
}
         
export default SignupForm;
