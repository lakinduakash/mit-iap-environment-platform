# Module Overview

## Description

This is the service for access github APIs'

## Utility Functions

### assignLabel

The `assignLabel` function will assign the labels to a given issue.

- **Parameters**

  - issueNumber - Issue number which the given labels should be assigned to.
  - labels - Array of labels which should be assigned to the issue.

- **return** - Returns a **string[]** which includes the status code and the message.

### checkLabel

The `checkLabel` function is used to check whether the given label is available or not.

- **Parameters**

  - labelName - Name of the label.

- **return** - Returns a **string[]** which indicates the status.

### createLabel

The `createLabel` function will create a label in a specified git repository.

- **Parameters**

  - labelName - Name of the label.
  - labelDescription - Description of the label.

- **return** - Returns a **string[]** which indicates the status.

### createLabelIfNotExists

The `createLabelIfNotExists` function creates a label if the relevant label is not yet available.

- **Parameters**

  - labelName - Name of the label.
  - labelDescription - Description of the label.

- **return** - Returns a **string[]** which indicates the status.

### getNotFoundStatus

The `getNotFoundStatus` function returns the not found status and the code as a string[]

- **return** - Returns status and status code.

### getStatus

The `getStatus` function will return the status of the **http:Response**

- **Parameter**

  - response - Http response.

- **return** - Returns a **string[]** which includes the status code and the message.
