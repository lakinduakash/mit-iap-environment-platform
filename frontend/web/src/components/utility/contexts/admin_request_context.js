import React, { useState, createContext } from "react";

export const AdminRequestContext = createContext();

const AdminRequestProvider = props => {
  const [id, setId] = useState(null);
  const [title, setTitle] = useState(null);
  const [state, setState] = useState(null);
  const [body, setBody] = useState(null);
  const [owner, setOwner] = useState(null);
  const [tags, setTags] = useState(null);
  const [assignees, setAssignees] = useState(null);

  return (
    <AdminRequestContext.Provider
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
    </AdminRequestContext.Provider>
  );
};

export default AdminRequestProvider;
