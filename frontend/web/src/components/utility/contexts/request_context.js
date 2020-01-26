import React, { useState, createContext } from "react";

export const RequestContext = createContext();

const RequestProvider = props => {
  const [id, setId] = useState(null);
  const [title, setTitle] = useState(null);
  const [state, setState] = useState(null);
  const [body, setBody] = useState(null);

  return (
    <RequestContext.Provider
      value={[id, title, state, body, setId, setTitle, setState, setBody]}
    >
      {props.children}
    </RequestContext.Provider>
  );
};

export default RequestProvider;
