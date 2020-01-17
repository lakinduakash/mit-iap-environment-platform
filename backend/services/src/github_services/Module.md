# Module Overview

## Description

This is the service for access github APIs'

## Utility Functions

### assignLabel

The `assignLabel` function will assign the labels to the given issue.

- **Parameters**

  - issueNumber - The issue number which all the given labels are assigned.
  - labels - Array of labels which should assign to the issue.

- **return** - The function will return the **string[]** which includes the status code and the message.

### checkLabel

The `checkLabel` function use to check whether the given label is available or not.

- **Parameters**

  - labelName - The checking label name.

- **return** - The `checkLabel` function will return **string[]** to indicate the status.

### createLabel

The `createLabel` Function will create a label in github in particular repositary.

- **Parameters**

  - labelName - The creating label name.
  - labelDescription - The description of the label

- **return** - The `createLabel` function will return **string[]** to indicate the status.

### createLabelIfNotExists

The `createLabelIfNotExists` function creates a label if the relevant label is not available.

- **Parameters**

  - labelName - The creating label name.
  - labelDescription - The description of the label

- **return** - The `createLabelIfNotExists` function will return **string[]** to indicate the status.

### getNotFoundStatus

The `getNotFoundStatus` function returns the not found status and the code as a string[]

- **return** - Returns not found status and status code.

### getStatus

The `getStatus` function will return the status of the **http:Response**

- **Parameter**

  - response - Inputting reponse

- **return** - The function will return the **string array** which includes the status code and the message.
