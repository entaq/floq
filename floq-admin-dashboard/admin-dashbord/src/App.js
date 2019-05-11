import React, { Component } from "react";
import "./App.css";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { Provider } from "react-redux";
import { UserIsAuthenticated, UserIsNotAuthenticated } from "./Auth";
import store from "./store";
import Login from "./components/Login";
import Dashboard from "./components/Dashboard";
import AppNavBar from "./components/AppNavBar";
import Flagged from "./components/flagged/Flagged";

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
      <Route exact path="/flagged" component={Flagged} />
    </div>
  );
};

export default App;
