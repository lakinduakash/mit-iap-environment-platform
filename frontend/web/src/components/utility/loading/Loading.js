import React from "react";
import Loader from "react-loader-spinner";
import "./loading.css";

const RenderLoading = () => {
  return (
    <React.Fragment>
      <div className="loader-outer">
        <div className="loader-basic">
          <Loader
            className="loader-inner"
            type="ThreeDots"
            color="#808080"
            width={100}
          />
          <h2>Loading</h2>
        </div>
      </div>
    </React.Fragment>
  );
};

export default RenderLoading;
