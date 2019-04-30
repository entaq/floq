import React, { Component } from "react";
import "./App.css";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { Provider } from "react-redux";
import { UserIsAuthenticated, UserIsNotAuthenticated } from "./Auth";
import store from "./store";
import Login from "./components/Login";
import Dashboard from "./components/Dashboard";
import AppNavBar from "./components/AppNavBar";

console.log(store);
class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <Router>
          <div className="App">
            <Switch>
              <Route
                exact
                path="/login"
                component={UserIsNotAuthenticated(Login)}
              />
              <Route
                component={UserIsAuthenticated(AuthenticatedContainerLayout)}
              />
            </Switch>
          </div>
        </Router>
      </Provider>
    );
  }
}

// const LoginContainerLayout = () => {
//   return <Login />;
// };

const AuthenticatedContainerLayout = () => {
  return (
    <div>
      <AppNavBar />
      <Route exact path="/" component={Dashboard} />
    </div>
  );
};

export default App;
