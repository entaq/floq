import React, { Component } from "react";
import appicon from "./appicon.png";
class Login extends Component {
  render() {
    return (
      <div className="login">
        <div className="container">
          <div className="row-fluid">
            <div className="col-md-4 m-auto">
              <h3 className="display-5 text-center">Floq Admin Dashboard</h3>
              <div className="card">
                <div className="card-body">
                  <form class="form-signin">
                    <div class="text-center mb-4">
                      <img
                        class="mb-4"
                        src={appicon}
                        alt=""
                        width="72"
                        height="72"
                      />
                    </div>

                    <div class="form-label-group mt-4">
                      <input
                        type="email"
                        id="inputEmail"
                        class="form-control"
                        placeholder="Email address"
                        required
                        autofocus
                      />
                    </div>
                    <br />
                    <div class="form-label-group mb-3">
                      <input
                        type="password"
                        id="inputPassword"
                        class="form-control"
                        placeholder="Password"
                        required
                      />
                    </div>

                    <div class="checkbox mb-3" />
                    <button
                      class="btn btn-lg btn-primary btn-block"
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

export default Login;
