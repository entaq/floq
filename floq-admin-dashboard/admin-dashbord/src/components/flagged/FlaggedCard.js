import React, { Component } from "react";
import {
  exctractCliqName,
  REF_PHOTOBUCKET,
  deleteFlagged,
  unflagPhoto
} from "../../services/database";
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
          this.setState({ img: x });
        });
    }
  }

  imageClicked() {
    const { img } = this.state;
    if (img) {
      window.open("", "_blank").document.write(
        `<img width="80%" 
          height="80%" style="object-fit : contain" 
          src=${img} alt="Reported">`
      );
    }
  }

  deleteFlagged() {
    const { cliqID, fileID, userID, id } = this.props.content;
    console.log(this.props.content);

    deleteFlagged(id, userID, cliqID, fileID).then(x => {
      alert("Removed succesfully");
    });
  }

  unflagPhoto() {
    const { id } = this.props.content;
    unflagPhoto(id).then(x => {
      alert("Unflagged");
    });
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
              height="350px"
              style={{ objectFit: "cover" }}
              onClick={this.imageClicked.bind(this)}
            />
          ) : (
            <img
              src={placeholder}
              alt="REported Image"
              className="card-img-top"
              height="350px"
              style={{ objectFit: "cover" }}
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
            <a
              onClick={this.unflagPhoto.bind(this)}
              className=" btn btn-primary card-link text-white float-left"
            >
              Unflag Photo
            </a>
            <a
              onClick={this.deleteFlagged.bind(this)}
              className="btn btn-danger card-link text-white float-right"
            >
              Delete Photo
            </a>
          </div>
        </div>
      </div>
    );
  }
}

export default FlaggedCard;
