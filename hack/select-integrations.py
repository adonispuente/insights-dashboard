#!/usr/bin/env python3

import os
import re
import sys
from subprocess import check_output
from collections import defaultdict
from typing import Callable
import json

import yaml

dir_path = os.path.dirname(os.path.realpath(__file__))

ORIGIN_BRANCH = os.getenv("ORIGIN_BRANCH", "remotes/origin/master")


def get_integrations(data):
    integrations = {}
    for _, df in data["data"].items():
        if df["$schema"] == "/app-sre/integration-1.yml":
            integrations[df["name"]] = df

    return integrations


def get_modified_files():
    return check_output(["git", "diff", ORIGIN_BRANCH, "--name-only"]).decode().split()


def get_data_schema(data, modified_file):
    """get the schema of a file coming from data dir. If the file does not
    exist, it has been deleted, so get it from git"""

    # modified_file represents the git path, but not the keys of data['data']
    # because the leading `data` or `test_data` has been stripped. We need to calculate it
    # here to be able to fetch it from data
    data_path = modified_file[modified_file.find(os.path.sep) :]

    if data_path in data["data"]:
        # file is present in data.json, we can obtain it from there
        datafile = data["data"][data_path]
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ["git", "show", "{}:{}".format(ORIGIN_BRANCH, modified_file)]
        ).decode()
        datafile = yaml.safe_load(datafile_raw)

    return datafile["$schema"]


def get_resource_schema(data, modified_file):
    """get the schema of a file coming from resources dir. If the file does
    not exist, it has been deleted, so get it from git"""

    # modified_file represents the git path, but not the keys of
    # data['resources'] because the leading `resources` has been stripped. We
    # need to calculate it here to be able to fetch it from data
    data_path = modified_file[len("resources") :]

    schema = None
    if data_path in data["resources"]:
        # file is present in data.json, we can obtain it from there
        schema = data["resources"][data_path]["$schema"]
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ["git", "show", "{}:{}".format(ORIGIN_BRANCH, modified_file)]
        ).decode()
        schema_re = re.compile(r"^\$schema: (?P<schema>.+\.ya?ml)$", re.MULTILINE)
        s = schema_re.search(datafile_raw)
        if s:
            schema = s.group("schema")

    return schema


def get_modified_schemas(data, modified_files, is_test_data):
    data_path = "test_data/" if is_test_data else "data/"
    schemas = set()
    for modified_file in modified_files:
        # This makes sure only yaml files will be treated as schemas files
        if modified_file.startswith(data_path) and (
            modified_file.endswith(".yaml") or modified_file.endswith(".yml")
        ):
            schemas.add(get_data_schema(data, modified_file))

        if modified_file.startswith("resources/"):
            schema = get_resource_schema(data, modified_file)
            if schema:
                schemas.add(schema)

    return schemas


def get_integrations_by_schema(integrations, schema):
    matches = set()
    for int_name, integration in integrations.items():
        if schema in integration["schemas"]:
            matches.add(int_name)
    return matches


def print_cmd(
    integration,
    select_all,
    non_bundled_data_modified,
    int_name,
    has_integrations_changes=False,
):
    """
    Prints the command to run a integration instance.

    Args:
        integration: The integration object
        select_all (bool): A flag indicating whether to run every integration.
        non_bundled_data_modified (bool): A flag indicating whether non-bundled data has been modified.
        int_name (str): The name of the integration to run.
        has_integrations_changes (bool): A flag indicating whether there are changes to the integrations definitions.

    Returns:
        None
    """
    pr = integration["pr_check"]
    cmd = ""
    if pr.get("state"):
        cmd += "STATE=true "
    if pr.get("sqs"):
        cmd += "SQS_GATEWAY=true "
    if pr.get("no_validate_schemas"):
        cmd += "NO_VALIDATE=true "
    if not select_all and pr.get("early_exit") and not has_integrations_changes:
        cmd += "EARLY_EXIT=true "
        if pr.get("check_only_affected_shards"):
            cmd += "CHECK_ONLY_AFFECTED_SHARDS=true "

    if int_name == "change-owners":
        if select_all or non_bundled_data_modified:
            # select_all=true means that files outside the bundle has changed
            # `change-owners`` only operates on bundle data and would be blind to other
            # changes. therefore we run the integration in `limited` mode to let
            # it know that it can't make full decisions about the merge
            cmd += "CHANGE_TYPE_PROCESSING_MODE=limited "
        else:
            # select_all=false means that only datafiles have changed. this
            # means that all changes of an MR are reflected in the bundle
            # and `change-owners` sees the full picture and can make informed
            # decisions about self-serviceability
            cmd += "CHANGE_TYPE_PROCESSING_MODE=authoritative "
    if int_name == "vault-manager":
        cmd += "run_vault_reconcile_integration &"
    elif int_name == "user-validator":
        cmd += "run_user_validator &"
    elif int_name == "account-notifier":
        cmd += "run_account_notifier &"
    elif int_name == "git-partition-sync":
        cmd += "run_git_partition_sync_integration &"
    elif int_name == "terraform-resources":
        cmd = print_cmd_terraform_resources(integration, cmd)
    elif int_name == "terraform-repo":
        # tf_repo_int is a wrapper around running terraform repo and the executor
        # so we include the command args for terraform-repo int to run with
        cmd += f"run_tf_repo_int {pr['cmd']} &"
    else:
        cmd += f"run_int {pr['cmd']} &"

    print(cmd)


def get_shard_spec_overrides_from_int(integration):
    """
    Get the shardSpecOverrides configuration from the managed block in the
    integration spec. At PR time we only care about imageRef (this can be extended with
    extraArgs in the future.)
    :param integration: the integration spec
    """
    shard_spec_overrides = {}

    namespaces = integration.get("managed")
    for ns in namespaces:
        sharding = ns.get("sharding")
        if sharding and sharding.get("shardSpecOverrides"):
            for override in sharding.get("shardSpecOverrides"):
                if not override.get("imageRef"):
                    continue
                shard_spec_overrides[override["shard"]["$ref"]] = override

    return shard_spec_overrides.values()


def print_cmd_terraform_resources(integration, cmd):
    """Terraform-resources print_cmd specific function.
    """
    pr = integration["pr_check"]
    shard_spec_overrides = get_shard_spec_overrides_from_int(integration)
    if not shard_spec_overrides:
        cmd += f"run_int {pr['cmd']} &"
    else:
        overrided_shards = set()
        image_shards_map = get_image_ref_shards_map(
            lambda shard: shard["$ref"].split("/")[2],
            shard_spec_overrides
        )
        for image_ref, shards in image_shards_map.items():
            overrided_shards.update(shards)
            acc_param = [" --account-name " + ac for ac in shards]
            shard_cmd = (
                f"ALIAS={pr['cmd']}_override_{image_ref} "
                f"IMAGE={image_ref} "
                f"run_int {pr['cmd']}{''.join(acc_param)} &"
            )
            print(f"{cmd}{shard_cmd}")

        # Run the integration excluding the overrided shards
        if overrided_shards:
            ex_acc_param = [" --exclude-accounts " + ac for ac in overrided_shards]
            cmd += f"run_int {pr['cmd']}{''.join(ex_acc_param)} &"
    return cmd


def get_image_ref_shards_map(
        get_shard_id: Callable[[str], str],
        shard_spec_overrides: list):
    """
    Returns a map array of shards for each unique
    image ref set shardSpecOverrides
    """
    result = defaultdict(set)
    shard_id = ""
    for override in shard_spec_overrides:
        shard_id = get_shard_id(override["shard"])
        image_ref = override["imageRef"]
        result[image_ref].add(shard_id)

    return result


def print_pr_check_cmds(
    integrations,
    selected=None,
    select_all=False,
    non_bundled_data_modified=False,
    has_integrations_changes=False,
):
    if selected is None:
        selected = []
    for int_name, integration in integrations.items():
        pr = integration.get("pr_check")
        if not pr or pr.get("disabled"):
            continue

        always_run = pr.get("always_run")
        if int_name not in selected and not select_all and not always_run:
            continue

        print_cmd(
            integration,
            select_all,
            non_bundled_data_modified,
            int_name,
            has_integrations_changes=has_integrations_changes)


def main():
    # chdir to git root
    os.chdir("{}/..".format(dir_path))

    # grab data
    with open(sys.argv[1], "r") as f:
        data = json.load(f)

    is_test_data = True if sys.argv[2] == "yes" else False

    integrations = get_integrations(data)
    modified_files = get_modified_files()

    def any_modified(func):
        return any(func(p) for p in modified_files)

    def all_modified(func):
        return all(func(p) for p in modified_files)

    if all_modified(lambda p: re.match(r"^(.*\.md|docs/)", p)):
        # only docs: no need to run pr check
        return

    non_bundled_data_modified = any_modified(
        lambda p: not re.match(r"^(data|resources)/", p)
    )
    has_integrations_changes = any_modified(
        lambda p: re.match(r"^data/integrations/", p)
    )

    if any_modified(lambda p: not re.match(r"^(data|resources|docs|test_data)/", p)):
        # unknow case: we run all integrations
        print_pr_check_cmds(
            integrations,
            select_all=True,
            non_bundled_data_modified=non_bundled_data_modified,
            has_integrations_changes=has_integrations_changes,
        )
        return

    selected = set()

    # list of integrations based on the datafiles that are changed
    modified_schemas = get_modified_schemas(data, modified_files, is_test_data)
    for schema in modified_schemas:
        schema_integrations = get_integrations_by_schema(integrations, schema)
        selected = selected.union(schema_integrations)

    # list of integrations based on resources/
    # TEMPORARY PATH BASED HACK
    if any_modified(lambda p: re.match(r"^resources/terraform/", p)):
        selected.add("terraform-resources")
    if any_modified(lambda p: re.match(r"^resources/jenkins/", p)):
        selected.add("jenkins-job-builder")
    if any_modified(
        lambda p: re.match(r"^resources/", p)
        and not re.match(r"resources/(terraform|jenkins)/", p)
    ):
        selected.add("openshift-routes")
        selected.add("openshift-resources")
        selected.add("openshift-tekton-resources")
    # We want to run template-tester whenever a jinja2 template changes
    # This might also happen on resource templates, thus we cannot infer
    # a schema
    if any_modified(lambda p: re.match(r"^.*\.j2$", p)) and is_test_data:
        selected.add("template-tester")

    print_pr_check_cmds(
        integrations,
        selected=selected,
        non_bundled_data_modified=non_bundled_data_modified,
        has_integrations_changes=has_integrations_changes,
    )


if __name__ == "__main__":
    main()
