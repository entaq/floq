import React from "react";
import spinner from "../img/spinner.gif";

export default () => {
  return (
    <div className="loadin">
      <img
        src={spinner}
        alt="Loading"
        style={{ width: "200px", margin: "auto", display: "block" }}
      />
    </div>
  );
};
