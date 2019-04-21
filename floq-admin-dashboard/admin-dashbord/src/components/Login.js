import React, { Component } from "react";
import appicon from "./appicon.png";
import TextFieldGroup from "./TextinputGroup";
import { compose } from "redux";
import { connect } from "react-redux";
import { firebaseConnect } from "react-redux-firebase";
import PropTypes from "prop-types";

class Login extends Component {
  constructor() {
    super();

    this.state = {
      email: "",
      password: "",
      errors: {}
    };

    this.onChange = this.onChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }

  onChange = e => {
    this.setState({ [e.target.name]: e.target.value });
  };

  onSubmit = e => {
    e.preventDefault();
    const userData = {
      email: this.state.email,
      password: this.state.password
    };
    console.log(userData);
    const { firebase } = this.props;

    firebase
      .login(userData)
      .catch(err =>
        this.setState({ errors: { email: "Invalid user credentials" } })
      );
    //this.props.loginUser(userData);
  };

  render() {
    const { errors } = this.state;
    return (
      <div className="login">
        <div className="container">
          <div className="row-fluid">
            <div className="col-md-6 m-auto">
              <h3 className="display-5 text-center text-white">
                Floq Admin Dashboard
              </h3>
              <div className="card mt-5 shadow-lg p-3 mb-5 bg-white rounded">
                <div className="card-body">
                  <form className="form-signin" onSubmit={this.onSubmit}>
                    <div className="text-center mb-4">
                      <img
                        className="mb-4"
                        src={appicon}
                        alt=""
                        width="72"
                        height="72"
                      />
                    </div>
                    <TextFieldGroup
                      placeholder="Email Addresss"
                      name="email"
                      type="email"
                      value={this.state.email}
                      onChange={this.onChange}
                      error={errors.email}
                    />
                    <TextFieldGroup
                      placeholder="Password"
                      name="password"
                      type="password"
                      value={this.state.password}
                      onChange={this.onChange}
                      error={errors.password}
                    />
                    <button
                      style={{ backgroundColor: "#4ecdc4", border: "none" }}
                      className="btn btn-lg btn-primary btn-block"
                      type="submit"
                    >
                      Sign in
                    </button>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

Login.propTypes = {
  firebase: PropTypes.object.isRequired
};

export default firebaseConnect()(Login);
