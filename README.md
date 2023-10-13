# aras-pre-post-upgrade-run

Solution of handling pre- and post actions on database upgrades (imports) to Aras Innovator

- [Background](#background)
- [The problem this solution solves](#the-problem-this-solution-solves)
- [The concept](#the-concept)
- [Supported/verified](#supportedverified)
- [Technical description](#technical-description)
  - [Packages](#packages)

## Background

When working with Aras Innovator the updates are done via Aras Import tool. The tool imports packages to an Aras Innovator environment. (Package have been exported via Aras Export tool from another environment. )  
The Import tool does add and update configurations in the database, but it does not delete configurations and other more complex stuff.  
Therefore deleting configurations and doing other post-import stuff needs to be taken care in some other way.  
The solutions I have seen - at different customers - is having developed an own tool for it, using [ArasDeveloperTool](https://github.com/polyfacet/ArasDeveloperTool) or some other manual handling of it.  
Use case examples:  

- Deleting obsolete fields from Forms
- Deleting obsolete workflow paths/nodes from workflows.
- Minor migration of data
  - Setting a default value on all existing items of a specific type
  - Delete/migrate lists

## The problem this solution solves

This solutions aims to remove the need of using another tool than the Import/ConsoleUpgrade tool to update an Aras environment. As using another tool most often adds to the complexity of the deployment.  
With this solution we can simply use Aras methods. No need to manage/learn how a different tool works, as this solution is pure standard "Aras configuration/development"

## The concept

The simple idea is to hook in a method on the DatabaseUpgrade item type, that triggers specific pre- and post run methods based on the Release target.  
See examples: [HC_DatabaseUpgradePreRun](./src/packages/pre_run/Import/Method/HC_DatabaseUpgradePreRun.xml) and [HC_DatabaseUpgradePostRun](./src/packages/post_run/Import/Method/HC_DatabaseUpgradePostRun.xml)

## Supported/verified

The solution is developed on Release 2023 of Aras Innovator.  
The solution has been tested on the following releases.

- R22?

## Technical description

### Packages

- se.hilleconsultit.hc_db_upgrade (HC_DatabaseUpgradeExt)
- se.hilleconsultit.hc_db_upgrade.pre_run (HC_DatabaseUpgradePreRun)
- se.hilleconsultit.hc_db_upgrade.post_run (HC_DatabaseUpgradePostRun)
