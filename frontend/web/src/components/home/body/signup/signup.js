import React, { useState } from "react";
import { makeStyles } from "@material-ui/core/styles";
import TextField from "@material-ui/core/TextField";
import Checkbox from "@material-ui/core/Checkbox";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Button from "@material-ui/core/Button";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import Avatar from "@material-ui/core/Avatar";
import Typography from "@material-ui/core/Typography";
import CssBaseline from "@material-ui/core/CssBaseline";
import Container from "@material-ui/core/Container";
import { useHistory } from "react-router-dom";
import Box from "@material-ui/core/Box";
import Link from "@material-ui/core/Link";

const styles = makeStyles(theme => ({
  avatar: {
    margin: theme.spacing(1),
    backgroundColor: "#277c2f"
  },
  root: {
    marginTop: theme.spacing(1),
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  form: {
    width: "100%", // Fix IE 11 issue.
    marginTop: theme.spacing(1)
  },
  checkbox: {
    color: "#277c2f"
  },
  button: {
    width: "45%",
    fontSize: 13,
    backgroundColor: "#277c2f",
    color: "white",
    "&:hover": {
      backgroundColor: "#0d5113"
    }
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

function SignupForm() {
  const classes = styles();

  const [firstName, setFirstName] = useState();
  const [lastName, setLastName] = useState();
  const [email, setEmail] = useState();
  const [phoneNumber, setPhoneNumber] = useState();
  const [address, setAddress] = useState();
  const [password, setPassword] = useState();
  const [confirmPassword, setConfirmPassword] = useState();
  const history = useHistory();

  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.root}>
        <Avatar className={classes.avatar}>
          <LockOutlinedIcon />
        </Avatar>
        <Typography component="h1" variant="h5">
          Sign Up
        </Typography>
        <form className={classes.form} noValidate>
          <TextField
            variant="outlined"
            margin="normal"
            id="firstName"
            name="firstName"
            label="First Name"
            placeholder="First Name"
            onChange={() => setFirstName()}
            value={firstName}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="lastName"
            name="lastName"
            label="Last Name"
            placeholder="Last Name"
            onChange={() => setLastName()}
            value={lastName}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="email"
            name="email"
            label="Email"
            placeholder="Email"
            onChange={() => setEmail()}
            value={email}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="phoneNumber"
            name="phoneNumber"
            label="Phone Number"
            placeholder="Phone Number"
            onChange={() => setPhoneNumber()}
            value={phoneNumber}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="address"
            name="address"
            label="Address"
            placeholder="Address"
            onChange={() => setAddress()}
            value={address}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="password"
            name="password"
            label="Password"
            placeholder="Password"
            type="password"
            onChange={() => setPassword()}
            value={password}
            fullWidth
          />
          <TextField
            variant="outlined"
            margin="normal"
            id="confirmPassword"
            name="confirmPassword"
            label="Confirm Password"
            placeholder="Confirm Password"
            type="password"
            onChange={() => setConfirmPassword()}
            value={confirmPassword}
            fullWidth
          />
          <FormControlLabel
            control={<Checkbox value="remember" className={classes.checkbox} />}
            label="Remember me"
          />
          <br />
          <Button type="signup" className={classes.button}>
            Sign Up
          </Button>
          <Button
            style={{ marginLeft: "10%" }}
            onClick={() => history.push("/login")}
            className={classes.button}
          >
            Back
          </Button>
        </form>
      </div>
      <Box mt={8}>
        <Copyright />
      </Box>
    </Container>
  );
}

export default SignupForm;
