import React, { Component } from "react";
import { exctractCliqName, REF_PHOTOBUCKET } from "../../services/database";
import * as firebase from "firebase";
import placeholder from "../../img/17.jpg";

class FlaggedCard extends Component {
  constructor() {
    super();
    this.state = {
      img: null
    };
  }

  componentDidMount() {
    if (this.props.content.fileID) {
      const fileID = this.props.content.fileID;
      firebase
        .storage()
        .ref(`${REF_PHOTOBUCKET}/${fileID}`)
        .getDownloadURL()
        .then(x => {
          console.log("The props are " + x);
          this.setState({ img: x });
        });
    }
  }

  componentWillReceiveProps(nextProps) {}

  render() {
    const { cliqID, flaggers, userName, likes, fileID } = this.props.content;
    return (
      <div className="col-lg-6 col-sm-8 col-md-6 mb-4 col-xl-4 align-items-center">
        <div className="card">
          {this.state.img ? (
            <img
              src={this.state.img}
              alt="REported Image"
              className="card-img-top"
            />
          ) : (
            <img
              src={placeholder}
              alt="REported Image"
              className="card-img-top"
            />
          )}
          <div className="card-body">
            <h6 className="py-4">
              <span className="float-left">Uploaded By {userName}</span>{" "}
              <span className="float-right text-align-left">
                Cliq: {exctractCliqName(cliqID)}
              </span>
            </h6>
            <h6>
              <span className="float-left">
                Flagged By {flaggers.length} Users
              </span>{" "}
              <span className="float-right text-align-left">{likes} Likes</span>
            </h6>
          </div>

          <div className="card-footer">
            <a href="#" className=" btn btn-primary card-link float-left">
              Unflag Photo
            </a>
            <a href="#" className="btn btn-danger card-link float-right">
              Delete Photo
            </a>
          </div>
        </div>
      </div>
    );
  }
}

export default FlaggedCard;
