# Module Overview

## Description

This is the service for access github APIs'

## Utility Functions

### checkLabel

The `checkLabel` function use to check whether the given label is available or not.

- **Parameters**

  - labelName - The checking label name.
  - repoUser - The name of the repositary owner.
  - repoName - The name of the repositary.

- **return** - The `checkLabel` function will return **json** to indicate the status.

### createLabel

The `createLabel` Function will create a label in github in particular repositary.

- **Parameters**

  - repoUser - The name of the repositary owner.
  - repoName - The name of the repositary.
  - labelName - The creating label name.
  - labelDescription - The description of the label

- **return** - The `createLabel` function will return **json** to indicate the status.

### getNotFoundStatus

The `getNotFoundStatus` function returns the not found status and the code as a json

- **return** - Returns not found status and status code.

### getStatus

The `getStatus` function will return the status of the **http:Response**

- **Parameter**

  - response - Inputting reponse

- **return** - The function will return the status code and the description as a json.
