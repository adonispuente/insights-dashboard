# Unset CPU Limits

[TOC]

## Background

Set `limits.cpu` can cause performance issues for some applications.
This is because cfs will throttle the pod when it used up the quota determined by `limits.cpu` value.
This can cause the application to run slower, or even unexpectedly crash.

## Solution

1. Ensure `requests.cpu` is set to a reasonable value.
1. Unset `limits.cpu` in the deployment configuration.
1. Disable DVO alert for `unset-cpu-requirements`
   1. Set deployment annotation following doc from [KubeLinter](https://docs.kubelinter.io/#/configuring-kubelinter?id=ignoring-violations-for-specific-cases)
        ```yaml
        metadata:
          annotations:
            ignore-check.kube-linter.io/unset-cpu-requirements: "no cpu limits"
        ```
   1. If `metadata` is not accessible, then set app labels following doc from [DVO](/docs/app-sre/dvo.md#disable-dvo-checks)
        ```yaml
        labels:
          deployment_validation_operator_unset_cpu_requirements: "no cpu limits"
        ```

## When to use CPU limits

CPU limits should be unset by default, unless there is a good reason to set it.
Can find good reasons in the paper [CPU bandwidth control for CFS](https://research.google/pubs/pub36669/)

> There are many enterprise scenarios where this functionality is useful.
> In particular are the cases of pay-per-use environments,
> and user facing services where provisioning is latency bounded.


## References

* [How Kubernetes applies resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#how-pods-with-resource-limits-are-run)
* [Disable CPU limits — unless you have a good use case](https://learnk8s.io/production-best-practices#:~:text=Disable%20CPU%20limits%20%E2%80%94%20unless%20you%20have%20a%20good%20use%20case)
* [Understanding resource limits in kubernetes: cpu time](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-cpu-time-9eff74d3161b)
* [Kubernetes resources under the hood — Part 3](https://medium.com/directeam/kubernetes-resources-under-the-hood-part-3-6ee7d6015965)
