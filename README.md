# aras-pre-post-upgrade-run

Solution of handling pre- and post actions on database upgrades (imports) to Aras Innovator

- [Background](#background)
- [The problem this solution solves](#the-problem-this-solution-solves)
- [The concept](#the-concept)
- [Supported/verified](#supportedverified)
- [Getting started](#getting-started)
- [How to example](#how-to-example)
- [Technical description](#technical-description)
  - [Packages](#packages)
- [Understanding the flow of the Aras Import Tool](#understanding-the-flow-of-the-aras-import-tool)

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

- 🟢 R2023
- 🟢 R22
- 🟢 R12SP14

## Getting started

0. Have an Aras Innovator environment.
1. Clone this repo
2. Configure: [env.config](./scripts/deploy/env.config)
3. Run [deploy.ps1](./scripts/deploy/deploy.ps1) to install solution
4. Run again to test. See log file <installpath>\Innovator\Server\temp\HC_DatabaseUpgrade.log

## How to example

As and example we would like to set a new start page for all users after we have made an update, e.g. to Release '28.12'.  
By including the post_run package '<package name="acme.aras.db_upgrade.post_run" path="post_run\Import">' and making it run as a final import package during the import (See next section) and modifying/including the hc_DatabaseUpgradePostRun method like:

``` csharp
...
actions.Add(new KeyValuePair<string, Action>("28.12", UpdateUsersStartPage));

...

void UpdateUsersStartPage() {
    LogMessage($"Starting UpdateUsersStartPage Post Run ");
    try {
        Item allUsers = inn.newItem("User","get");
        allUsers = allUsers.apply();
        ...

    }
    catch (Exception ex) {
        LogMessage(ex.ToString());
        // throw; // To throw or not, is the question. :)
    }
    LogMessage($"Completed UpdateUsersStartPage Post Run ");

}

```

I.e. write the method, and register/make it trigger when we run import for version '28.12' only.
Same concept for pre_run, but use the pre_run package and make it execute first and write the implementation in hc_DatabaseUpgradePreRun.

## Technical description

### Packages

- se.hilleconsultit.hc_db_upgrade (HC_DatabaseUpgradeExt)
- se.hilleconsultit.hc_db_upgrade.pre_run (HC_DatabaseUpgradePreRun)
- se.hilleconsultit.hc_db_upgrade.post_run (HC_DatabaseUpgradePostRun)

## Understanding the flow of the Aras Import Tool

As I been told by a colleague, after his empirical investigations the Import Tool handles the import order in the following way as described by this psuedo code.

``` vb

PackagesImported = new List(Of Package)
PackagesNotImportedInFirstRun = new List(Of Package)
 
Sub RunImport()
 
    packages As List(Of Package) = LoadPackagesFromMfFile
 
    For Each package In packages
        If ReadyForImport(package) Then
            ImportPackage(package)
            PackagesImported.Add(package)
        Else
            PackagesNotImportedInFirstRun.Add(package)
        End If
    Next For
 
    For Each package In PackagesNotImportedInFirstRun
        If packagesImported.Contains(package) Then
            Continue For ' I.e. already imported, continue with next
        End If
        importedPackages = ImportPackageWithDependencies(package) ' Run imports, with the dependencies first
        packagesImported.AddRange(importedPackages)
 
    Next For
 
End Sub
 
Function ReadyForImport(package As Package) As Boolean
    If Not HasDependencies(package) Then
        Return True
    End If
    If AllDependenciesImported(package) Then
        Return True
    End If
    Return False
End Function first
        packagesImported.AddRange(importedPackages)

    Next For

End Sub

Function ReadyForImport(package As Package) As Boolean
    If Not HasDependencies(package) Then
        Return True
    End If
    If AllDependenciesImported(package) Then
        Return True
    End If
    Return False
End Function

```

Below is an example on how the import will run, with order number in xml-comments, with some clarifying comments.

``` xml
<imports>
    <!-- 1 Has no dependencies -->
    <package name="se.hilleconsultit.hc_db_upgrade" path="db_upgrade\Import" />

    <!-- 2 Has all dependencies imported -->
    <package name="se.hilleconsultit.hc_db_upgrade.pre_run" path="pre_run\Import">
        <dependson name="se.hilleconsultit.hc_db_upgrade" />
    </package>

    <!-- 4  The dependency 'extendedhistory' is not imported, therefore skipping for next "loop" -->
    <package name="acme.aras.plm" path="plm\Import">
        <dependson name="acme.aras.extendedhistory" />
        <dependson name="se.hilleconsultit.hc_db_upgrade.pre_run" />
    </package>
        
    <!-- 3 -->
    <package name="acme.aras.extendedhistory" path="extendedhistory\Import" />
    
    <!-- 5 -->
    <package name="com.aras.history" path="history\Import" >
        <dependson name="acme.aras.plm" />
        <dependson name="acme.aras.extendedhistory" />
    </package>

    <!-- 6 -->
    <package name="com.aras.innovator.core" path=".\">
        <dependson name="com.aras.innovator.admin" />
        <dependson name="acme.aras.extendedhistory" />
    </package>

    <!-- 7 -->
    <package name="com.aras.innovator.cui_default" path=".\">
        <dependson name="com.aras.innovator.cui" />
    </package>

    <!-- 8 -->
    <package name="se.hilleconsultit.hc_db_upgrade.post_run" path="post_run\Import">
        <dependson name="acme.aras.plm" />
        <dependson name="com.aras.innovator.core" />
        <dependson name="acme.aras.extendedhistory" />
    </package>
  
</imports>

```

### Conclusion

After an initial import of a package, i.e. when we do updates to a package, it might be more correct to don't explicitly work with dependencies to make the import run in the correct order.  
But rather user a top-down approach with 'dependson' commented out. By doing this we avoid creating circular dependencies in the database, keeps the .mf file easier to follow. Leaving the dependson as comments, is to guide/help the developers to see how the package are supposed to depend on each other.