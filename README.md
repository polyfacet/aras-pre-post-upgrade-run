# aras-pre-post-upgrade-run

Solution of handling pre- and post actions on database upgrades (imports) to Aras Innovator

## Background

When working with Aras Innovator the updates are done via Aras Import tool. The tool imports packages to an Aras Innovator environment. (Package have been exported via Aras Export tool from another environment. )  
The Import tool does add and update configurations in the database, but it does not delete configurations and other more complex stuff.  
Therefore deleting configurations and doing other post-import stuff needs to be taken care in some other way.  
The solutions i have seen - at different customers - is having developed an own tool for it, using [ArasDeveloperTool](https://github.com/polyfacet/ArasDeveloperTool) or some other manual handling of it.  
Use case examples:  

- Deleting fields from Forms
- Deleting workflow paths/nodes from workflows.
- Minor migration of data
  - Setting a default value on all existing items of a specific type
  - Delete/migrate lists

## The problem this solution solves

This solutions aims to remove the need of using another tool than the Import/ConsoleUpgrade tool to update an Aras environment.

## The concept

The simple idea is to hook in a method on the DatabaseUpgrade item type, that triggers specific pre- and post run methods based on the Release target.
