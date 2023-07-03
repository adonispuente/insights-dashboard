# Git Permission Denied
Git operation permissions differ between the producer and consumer but a `permission denied` error can typically be attributed to the omission of `@devtools-bot` user as a `maintainer` on the target gitlab project.

## Producer
Producer only performs cloning of target gitlab projects. If the project is `private`, ensure `@devtools-bot` is a member. No specific role is required.

## Consumer
The consumer portion of git-partition-sync requires force-push permission to be configured for the `default/protected` branch. Ensure that this is reflected in the project's settings for the `maintainer` role and that `@devtools-bot` is a member of the role.
