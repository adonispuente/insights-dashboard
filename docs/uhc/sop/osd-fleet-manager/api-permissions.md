<h1>SOP Template</h1>
 
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 
 
- [1 Introduction](#1-introduction)
  - [1.1 Reference Articles](#11-reference-articles)
  - [1.2 Use Cases](#12-use-cases)
  - [1.3 Success Indicators](#13-success-indicators)
  - [1.4 Stakeholders](#14-stakeholders)
  - [1.5 Additional Details](#15-additional-details)
- [2 Procedure](#2-procedure)
  - [2.1 Plan](#21-plan)
  - [2.2 Prerequisites](#22-prerequisites)
  - [2.3 Execute](#23-execute)
  - [2.4 Validate](#24-validate)
  - [2.5 Issue All Clear](#25-issue-all-clear)
- [3 Troubleshooting](#3-troubleshooting)
- [4 References](#4-references)
 
<!-- END doctoc generated TOC please keep comment here to allow auto update -->
 
# 1 Introduction
 
This document defines the required step to add permissions to the Fleet Manager API
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
This procedure has to be executed when an user needs access to Fleet Manager API
 
## 1.3 Success Indicators
 
THe user can execute a REST request against Fleet Manager API
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
N/A 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sur you have access and have merge permissions to project https://gitlab.cee.redhat.com/service/ocm-resources
 
## 2.2 Prerequisites
 
None
 
## 2.3 Execute
 
In order to gain OSD Fleet Manager APIs, the user needs to be granted at least the [OSDFleetManagerViewer](https://gitlab.cee.redhat.com/service/uhc-account-manager/-/blob/master/pkg/api/roles/osd_fleet_manager_viewer.go) role. This provides the user with read-only access to OSD Fleet Manager APIs, enabling service clusters, management clusters, etc. to be inspected.

On top of that, the [OSDFleetManagerAdmin](https://gitlab.cee.redhat.com/service/uhc-account-manager/-/blob/master/pkg/api/roles/osd_fleet_manager_admin.go) role exists that permits modifications (creating, updating and deleting service/management clusters).

Use the ocm-resources repository to request this role granted against your user. An example in the staging OCM environment: https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-stage/users/jharting.osdfleetmanager.yaml#L9

NOTE: This role grants significant access and should only be granted to engineers who understand the implications of creating/deleting management/service clusters, especially in the production environment.
 
## 2.4 Validate
 
To validate permissions are applied, try sending an REST request to Fleet Manager API (ie: GET `/api/osd_fleet_mgmt/v1/service_clusters`)
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A 
# 4 References
 
N/A
