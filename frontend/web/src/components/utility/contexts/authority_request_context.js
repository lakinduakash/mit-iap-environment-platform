import React, { useState, createContext } from "react";

export const AuthorityRequestContext = createContext();

const AuthorityRequestProvider = props => {
  const [id, setId] = useState(null);
  const [title, setTitle] = useState(null);
  const [state, setState] = useState(null);
  const [body, setBody] = useState(null);
  const [owner, setOwner] = useState(null);
  const [tags, setTags] = useState(null);
  const [assignees, setAssignees] = useState(null);

  return (
    <AuthorityRequestContext.Provider
      value={[
        id,
        title,
        state,
        body,
        owner,
        tags,
        assignees,
        setId,
        setTitle,
        setState,
        setBody,
        setOwner,
        setTags,
        setAssignees
      ]}
    >
      {props.children}
    </AuthorityRequestContext.Provider>
  );
};

export default AuthorityRequestProvider;
