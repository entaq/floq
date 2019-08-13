import React, { Component } from "react";
import * as firebase from "firebase";
import {
  REF_FLPHOTOS,
  FIELD_CLIQ_ID,
  FIELD_FLAGGED
} from "../../services/database";
import FlaggedCard from "./FlaggedCard";

export default class Flagged extends Component {
  constructor() {
    super();
    this.state = {
      data: []
    };
  }

  componentDidMount() {
    firebase
      .firestore()
      .collection(REF_FLPHOTOS)
      .where(FIELD_FLAGGED, "==", true)
      .onSnapshot(queries => {
        const data = queries.docs;
        console.log(data);
        this.setState({ data });
      });
  }
  render() {
    const { data } = this.state;
    return (
      <div className="container-fluid">
        <div className="row">
          <div className="col text-center">
            <h6 className="display-4">Flagged Photos</h6>
          </div>
        </div>
        <div className="row">
          {data.map(doc => {
            const data = doc.data();
            data.id = doc.id;
            return <FlaggedCard key={doc.id} content={data} />;
          })}
        </div>
      </div>
    );
  }
}
