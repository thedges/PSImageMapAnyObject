# PSImageMapAnyObject

THIS SOFTWARE IS COVERED BY [THIS DISCLAIMER](https://raw.githubusercontent.com/thedges/Disclaimer/master/disclaimer.txt).

This package includes a Lightning Web Component to show a clickable [HTML image map](https://www.w3schools.com/tags/tag_map.asp). The component can be configured to point to any SObject to get the imagemap area details (shape, coordinates, etc...). Example uses for this component is to show an airport floor/terminal with concession vendors and you want to link the image map to actual Salesforce records for easy navigation. Any use cases that you want to map image locations to Salesforce records are candidates.

Here is sample of the component in action:

![alt text](https://github.com/thedges/PSImageMapAnyObject/blob/master/PSImageMapAnyObject.gif "Sample Image")

## Setup

For this component to work, you need to upload an image as static resource and create a few fields on an SObject that will drive the component. Here are details for setup:

1. Find the image you want to be the base for the component and upload as static resource. 
2. Next you will need to create following 5 fields on an sobject that will drive the component (you can name the fields whatever you like:
   * <b>Title:</b> Create a text field that stores a "title" for image map area. The value for this field should be unique for the image map. Suggest Text(50) but can be larger if needed.
   * <b>Shape:</b> Create a picklist field to store the shape for the image map area. The 3 picklist options to be defined are: circle, poly, and rect.
   * <b>Coordinates:</b> Create a text field to store the coordinates for the image map area. Suggest Text(255). Recommend using a tool like [this one](https://www.image-map.net/) to create your coordinates.
   * <b>RecordId:</b> Create a field that points to the record id you want to transition to if user clicks on this section of the map. This can be a simple text field that stores a record id or can be a Lookup field. Your choice.
   * <b>Details:</b> Create a formula field that returns a text field that contains HTML. This is used for the pop-up window when you hover over an image map area. You can specify exactly what you want to show in that area.
   
Here is example of the 5 fields:

| Label | API Name | Type | Options
|-----------|------|-------------|----|
| Title | Title__c | Text(50) | |
| Shape | Shape__c | Picklist | circle, poly, rect |
| Coordinates | Coordinates__c | Text(255) | |
| Account | Account__c | Lookup(Account) | This could be lookup to any sobject you want |
| Details | Details__c | Formula(Text) | see sample below |

Here is sample of formulat field for the Details__c field:
```
'<html>' +
'  <table>' +
'    <tr>' +
'      <td><b>Name:</b></td>' +
'      <td>' + Account__r.Name + '</td>' +
'    </tr>' +
'    <tr>' +
'      <td><b>Active:</b></td>' +
'      <td>' + TEXT(Account__r.Active__c) + '</td>' +
'    </tr>' +
'    <tr>' +
'      <td><b>Phone:</b></td>' +
'      <td>' +  Account__r.Phone  + '</td>' +
'    </tr>' +
'  </table>' +
'</html>'
```

After creating the above fields, you will need to edit each record in your target SObject and provide values for the 5 fields.

## Configuration Parameters

Here are the configuration parameters for the component:

| Parameter | Type | Description |
|-----------|------|-------------|
| Image Static Resource Name | String | Name of static resource of image |
| SObject API Name | String | API name of SObject that drives this component |
| Title Field API Name | String | Field that stores the title for the image map area (unique for map) |
| Record ID Field API Name | String | Field that stores the record id to transition to if area is clicked. Can be text field or lookup. |
| Shape Field API Name | String | Field that stores the shape (circle, poly, rect) of the image map area |
| Coordinates Field API Name | String | Field that stores the coordinates of the image map area |
| Details Field API Name | String | Field that stores the hover pop-up details. Should be a formula field that returns HTML. |
| Location of Hover Box  | String | Option where to display hover pop-up window (top-left, top-right, bottom-left, bottom-right or auto). Auto will position pop-up box based on quadrant you click in the image.  |
| Where Clause | String | Extra where clause phrase to help filter records to drive the map. Use if you use same Sobject to drive multiple maps. You can have extra clause like: Map_Name__c = 'Map1' |

Here is a sample configuration for reference:

![alt text](https://github.com/thedges/PSImageMapAnyObject/blob/master/PSImageMapAnyObject-Config.png "Sample Configuration")

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
