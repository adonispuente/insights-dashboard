#!/usr/bin/env python

import os
import re
import sys
from subprocess import check_output
import json

import yaml

dir_path = os.path.dirname(os.path.realpath(__file__))

ORIGIN_BRANCH = os.getenv('ORIGIN_BRANCH', 'remotes/origin/master')


def get_integrations(data):
    integrations = {}
    for df_path, df in data['data'].items():
        if df['$schema'] == '/app-sre/integration-1.yml':
            integrations[df['name']] = df

    return integrations


def get_modified_files():
    return check_output(['git', 'diff', ORIGIN_BRANCH, '--name-only']).split()


def get_data_schema(data, modified_file):
    """ get the schema of a file coming from data dir. If the file does not
    exist, it has been deleted, so get it from git """

    # modified_file represents the git path, but not the keys of data['data']
    # because the leading `data` or `test_data` has been stripped. We need to calculate it
    # here to be able to fetch it from data
    data_path = modified_file[modified_file.find(os.path.sep):]

    if data_path in data['data']:
        # file is present in data.json, we can obtain it from there
        datafile = data['data'][data_path]
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ['git', 'show', '{}:{}'.format(ORIGIN_BRANCH, modified_file)])
        datafile = yaml.safe_load(datafile_raw)

    return datafile['$schema']


def get_resource_schema(data, modified_file):
    """ get the schema of a file coming from resources dir. If the file does
    not exist, it has been deleted, so get it from git """

    # modified_file represents the git path, but not the keys of
    # data['resources'] because the leading `resources` has been stripped. We
    # need to calculate it here to be able to fetch it from data
    data_path = modified_file[len('resources'):]

    schema = None
    if data_path in data['resources']:
        # file is present in data.json, we can obtain it from there
        schema = data['resources'][data_path]['$schema']
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ['git', 'show', '{}:{}'.format(ORIGIN_BRANCH, modified_file)])
        schema_re = re.compile(r'^\$schema: (?P<schema>.+\.ya?ml)$',
                               re.MULTILINE)
        s = schema_re.search(datafile_raw)
        if s:
            schema = s.group('schema')

    return schema


def get_modified_schemas(data, modified_files, is_test_data):
    data_path = "test_data/" if is_test_data else "data/"
    schemas = set()
    for modified_file in modified_files:
        if modified_file.startswith(data_path):
            schemas.add(get_data_schema(data, modified_file))

        if modified_file.startswith("resources/"):
            schema = get_resource_schema(data, modified_file)
            if schema:
                schemas.add(schema)

    return schemas


def get_integrations_by_schema(integrations, schema):
    matches = set()
    for int_name, integration in integrations.items():
        if schema in integration['schemas']:
            matches.add(int_name)
    return matches


def print_cmd(pr, select_all, non_bundled_data_modified, int_name, override=None):
    cmd = ""
    if pr.get('state'):
        cmd += "STATE=true "
    if pr.get('sqs'):
        cmd += "SQS_GATEWAY=true "
    if pr.get('no_validate_schemas'):
        cmd += "NO_VALIDATE=true "
    if not select_all and pr.get('early_exit'):
        cmd += "EARLY_EXIT=true "
    elif int_name == "terraform-resources" and override is not None:
        cmd += "EARLY_EXIT=false "

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
        cmd += 'run_vault_reconcile_integration &'
    elif int_name == "user-validator":
        cmd += 'run_user_validator &'
    else:
        if override:
            # only qr integrations support sharding
            shard = override['awsAccount']["$ref"].split("/")[2]
            cmd += "ALIAS=" + pr['cmd'] + "_" + shard + " "
            cmd += "IMAGE=" + override['imageRef'] + " "
            cmd += "run_int " + pr['cmd'] + " --account-name " + shard +" &"
        else:
            cmd += "run_int " + pr['cmd'] + ' &'

    print(cmd)


def print_pr_check_cmds(integrations, selected=None, select_all=False,
                        non_bundled_data_modified=False):
    if selected is None:
        selected = []

    for int_name, integration in integrations.items():
        pr = integration.get('pr_check')
        if not pr or pr.get('disabled'):
            continue

        always_run = pr.get('always_run')
        if int_name not in selected and not select_all and not always_run:
            continue

        if pr.get("shardSpecOverride"):
            for override in pr.get("shardSpecOverride"):
                print_cmd(pr, select_all, non_bundled_data_modified, int_name, override)

        print_cmd(pr, select_all, non_bundled_data_modified, int_name)


def main():
    # chdir to git root
    os.chdir('{}/..'.format(dir_path))

    # grab data
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)

    is_test_data = True if sys.argv[2] == "yes" else False

    integrations = get_integrations(data)
    modified_files = get_modified_files()

    def any_modified(func):
        return any(func(p) for p in modified_files)

    def all_modified(func):
        return all(func(p) for p in modified_files)

    if all_modified(lambda p: re.match(r'^docs/', p)):
        # only docs: no need to run pr check
        return

    non_bundled_data_modified=any_modified(lambda p: not re.match(r'^(data|resources)/', p))

    if any_modified(lambda p: not re.match(r'^(data|resources|docs|test_data)/', p)):
        # unknow case: we run all integrations
        print_pr_check_cmds(
            integrations,
            select_all=True,
            non_bundled_data_modified=non_bundled_data_modified
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
    if any_modified(lambda p: re.match(r'^resources/terraform/', p)):
        selected.add('terraform-resources')
    if any_modified(lambda p: re.match(r'^resources/jenkins/', p)):
        selected.add('jenkins-job-builder')
    if any_modified(lambda p: re.match(r'^resources/', p) \
            and not re.match(r'resources/(terraform|jenkins)/', p)):
        selected.add('openshift-routes')
        selected.add('openshift-resources')
        selected.add('openshift-tekton-resources')

    print_pr_check_cmds(
        integrations,
        selected=selected,
        non_bundled_data_modified=non_bundled_data_modified
    )


if __name__ == '__main__':
    main()
