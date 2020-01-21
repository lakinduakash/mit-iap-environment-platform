// import React from "react";
// import {
//   Grid,
//   Checkbox,
//   Form,
//   Segment,
//   Message,
//   Button
// } from "semantic-ui-react";

// class LoginForm extends React.Component {
//   constructor(props) {
//     super(props);
//     this.state = {
//       email: "",
//       password: ""
//     };

//     this.handleInputChange.bind(this);
//   }

//   handleInputChange = event => {
//     const target = event.target;
//     const name = target.name;
//     const value = target.type === "checkbox" ? target.checked : target.value;

//     this.setState({
//       [name]: value
//     });
//   };

//   onLogin = () => {
//     //if(userAuthenticated){
//     //var id = document.getElementById("Email").value;
//     if (this.state.email === "user") {
//       //return  <Redirect  to='/' />
//       this.props.history.push("/user-dash");
//     } else if (this.state.email === "admin") {
//       this.props.history.push("/admin-dash");
//     }
//   };

//   render() {
//     return (
//       <Segment>
//         <Grid
//           columns={2}
//           textAlign="center"
//           padded
//           style={{ height: "100vh" }}
//           verticalAlign="middle"
//         >
//           <Grid.Column style={{ maxWidth: 1600 }}>
//             <Message>
//               MIT IAP Environment Platform is a service for customers to request
//               land for private or commercial reasons...
//             </Message>
//           </Grid.Column>
//           <Grid.Column textAlign="left" style={{ maxWidth: 400 }}>
//             <strong>Log in</strong>
//             <br />
//             <br />
//             <Form>
//               <Segment stacked>
//                 <Form.Input
//                   icon="user"
//                   iconPosition="left"
//                   placeholder="Email"
//                   name="email"
//                   onChange={this.handleInputChange}
//                   value={this.state.email}
//                 />
//                 <Form.Input
//                   type="password"
//                   icon="lock"
//                   iconPosition="left"
//                   placeholder="Password"
//                   name="password"
//                   onChange={this.handleInputChange}
//                   value={this.state.password}
//                 />
//                 <Checkbox label="Remember password" />
//                 <br></br>
//                 <br></br>
//                 <Button color="teal" type="login" onClick={this.onLogin}>
//                   Log in
//                 </Button>
//               </Segment>
//             </Form>
//             <Message>
//               New to us? <a href="/signup">Sign Up</a>
//             </Message>
//           </Grid.Column>
//         </Grid>
//       </Segment>
//     );
//   }
// }

// export default LoginForm;

import React from "react";
import Avatar from "@material-ui/core/Avatar";
import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import TextField from "@material-ui/core/TextField";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Checkbox from "@material-ui/core/Checkbox";
import Link from "@material-ui/core/Link";
import Grid from "@material-ui/core/Grid";
import Box from "@material-ui/core/Box";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";

const useStyles = makeStyles(theme => ({
  paper: {
    marginTop: theme.spacing(8),
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  avatar: {
    margin: theme.spacing(1),
    backgroundColor: "#5eba7d"
  },
  form: {
    width: "100%", // Fix IE 11 issue.
    marginTop: theme.spacing(1)
  },
  submit: {
    margin: theme.spacing(3, 0, 2),
    background: "#5eba7d",
    color: "white"
  }
}));

function Copyright() {
  return (
    <Typography variant="body2" color="textSecondary" align="center">
      {"Copyright © "}
      <Link color="inherit" href="https://material-ui.com/">
        Environmental Management Platform
      </Link>{" "}
      {new Date().getFullYear()}
      {"."}
    </Typography>
  );
}

class LoginForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      email: "",
      password: ""
    };

    this.handleInputChange.bind(this);
    this.formComponent.bind(this);
  }

  handleInputChange = event => {
    const target = event.target;
    const name = target.name;
    const value = target.type === "checkbox" ? target.checked : target.value;

    this.setState({
      [name]: value
    });
  };

  onLogin = () => {
    if (this.state.email === "user") {
      this.props.history.push("/user-dash");
    } else if (this.state.email === "admin") {
      this.props.history.push("/admin-dash");
    } else {
      this.props.history.push("/user-dash");
    }
  };

  formComponent = () => {
    const classes = useStyles();
    return (
      <Container component="main" maxWidth="xs">
        <CssBaseline />
        <div className={classes.paper}>
          <Avatar className={classes.avatar}>
            <LockOutlinedIcon />
          </Avatar>
          <Typography component="h1" variant="h5">
            Sign in
          </Typography>
          <form className={classes.form} noValidate>
            <TextField
              variant="outlined"
              margin="normal"
              required
              fullWidth
              id="email"
              label="Email Address"
              name="email"
              autoComplete="email"
              onChange={this.handleInputChange}
              value={this.state.email}
              autoFocus
            />
            <TextField
              variant="outlined"
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              autoComplete="current-password"
              onChange={this.handleInputChange}
              value={this.state.password}
            />
            <FormControlLabel
              control={
                <Checkbox value="remember" style={{ color: "#5eba7d" }} />
              }
              label="Remember me"
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              className={classes.submit}
              onClick={this.onLogin}
            >
              Sign In
            </Button>
            <Grid container>
              <Grid item>
                <Link href="/signup" variant="body2">
                  {"Don't have an account? Sign Up"}
                </Link>
              </Grid>
            </Grid>
          </form>
        </div>
        <Box mt={8}>
          <Copyright />
        </Box>
      </Container>
    );
  };

  render() {
    return <this.formComponent />;
  }
}

export default LoginForm;
