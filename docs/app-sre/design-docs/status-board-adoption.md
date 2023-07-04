# Design doc: Status Board Adoption

## Author/date


Jan-Hendrik Boll / July 2023


## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-5558


## Problem Statement

Publishing data from App-Interface in Status Board enables us to start using Web RCA during our incidents. This is because the application list from Status Board is used to populate the drop-down list that is available in web-rca.

We would want to have every product/application listed in App-Interface in Status Board. More details on status-board can be found here:

* [RFE](https://docs.google.com/document/d/1JmVVEGsPgpuwWkF1HKMNMMpLI-1uzlRzuU1_-OmpKuY/edit?pli=1#heading=h.j5gzm6wgeded)
* [Repository](https://gitlab.cee.redhat.com/service/status-board)

## Goals

* Publish Products and Applications from App-Interface to Status Board

## Non-objectives

* Adding services to Status Board
* This is not to be confused with status.redhat.com or status.quay.io, there is no connection between the Status Board and the Atlassian Status page.

## Proposal

Luckily we already have a hierachy for products and appliations, that we can use to create the necessary objects in Status Board [discussion](https://redhat-internal.slack.com/archives/C03M8A471V1/p1688388520514439). 

Create an integration, that creates the necessary ocm objects using the [status board api](https://api.openshift.com/?urls.primaryName=Status%20Board%20service).


```
---
$schema: /dependencies/status-board-1.yml

labels: {}

name: AppSRE status-board

ocm:
  $ref: data/dependencies/ocm/environments/production.yml


appSelector:
    - 'apps[?@.onboardingStatus=="OnBoarded"]'

products:
    - productEnvironment:
        $ref: /products/app-sre/environments/production.yml
    - productEnvironment:
        $ref: /products/app-interface/environments/production-int.yml
      appSelector:
        - 'apps[?@.name!="FooBar"]'
    ...
```

* Products need to be statically listed in the Status Board schema.
* Apps will be dynamically listed based on the products in Status Board schema. They can additionally be filtered using an appSelector.


## Alternatives considered

* Creating a static reference fom Status Board schema to corresponding apps


## Milestones
* Implement integration
* Onboard services
