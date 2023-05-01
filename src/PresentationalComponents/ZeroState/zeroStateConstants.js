/* eslint-disable max-len */
import messages from '../../Messages';

const ADVISOR_ZERO_STATE = {
    header: {
        description:
      `Using Red Hat’s expertise, analyze your RHEL hosts to identify and resolve risks to your environment's availability, performance, and stability.`,
        commands: [
            { plainText: ' 1. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'

            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            }
        ],
        bulletPoints: [
            'Detect misconfigurations, known problematic configurations, or highlight best practices.',
            'Prioritize & remediate risks via manual guidance or Ansible Automation.'
        ]
    },
    otherApps: [
        {
            title: 'Vulnerability',
            description: messages.vulnerabilityZeroState,
            link: '/insights/vulnerability'
        },
        {
            title: 'Patch',
            description: messages.patchZeroState,
            link: '/insights/patch'
        },
        {
            title: 'Resource Optimization',
            description: messages.resourceOptimizationZeroState,
            link: '/insights/ros'
        }
    ],
    documentation: [
        {
            title: 'Assessing RHEL Configuration Issues',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_rhel_configuration_issues_using_the_red_hat_insights_advisor_service/index'
        },
        {
            title: 'Generating Advisor Service Reports',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/generating_advisor_service_reports/index'
        },
        {
            title: 'Advisor APIs',
            link: 'https://console.redhat.com/docs/api/insights'
        },
        {
            title: 'Configuring notifications & Integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const COMPLIANCE_ZERO_STATE = {
    header: {
        description:
      'Monitor regulatory compliance policies of registered RHEL systems you must adhere to via OpenSCAP.',
        commands: [
            {
                step: '1. ',
                instructions: 'Install the supported SSG package on the host',
                numberedLink: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_security_policy_compliance_of_rhel_systems/proc-compl-getting-started_compl-getting-started'
            },
            { plainText: ' 2. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'
            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            },
            { plainText: ' 3. Initiate the compliance scan' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --compliance'
            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --compliance'
            }
        ],
        bulletPoints: [
            'Easily configure, customize, and deploy policies at scale.',
            'Generate reports for stakeholders and remediate via Ansible Automation.'
        ]
    },
    otherApps: [
        {
            title: 'Policies',
            description: messages.policiesZeroState,
            link: '/insights/policies'
        },
        {
            title: 'Vulnerability',
            description: messages.vulnerabilityZeroState,
            link: '/insights/vulnerability'
        },
        {
            title: 'Malware',
            description: messages.malwareZeroState,
            link: '/insights/malware'
        }
    ],
    documentation: [
        {
            title: 'Assessing and Monitoring Security Policy Compliance',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_security_policy_compliance_of_rhel_systems'
        },
        {
            title: 'Generating Compliance Service Reports',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/generating_compliance_service_reports'
        },
        {
            title: 'Insights Compliance - Supported configurations',
            link: 'https://access.redhat.com/articles/6644131'
        },
        {
            title: 'Compliance APIs',
            link: 'https://console.redhat.com/docs/api/compliance'
        },
        {
            title: 'Configuring notifications & integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const DRIFT_ZERO_STATE = {
    header: {
        description: 'Drift assists in performing root-cause analysis of issues during troubleshooting. It empowers system administrators to compare and track configuration changes in RHEL systems, define baselines, and ensure systems are compliant.',
        commands: [
            { plainText: ' 1. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'
            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            },
            { plainText: ' 2. Select two or more hosts to compare in the drift UI' }
        ],
        bulletPoints: [
            'Compare system configuration over time or to other systems.',
            'Define baselines as standard configuration systems must adhere to.'
        ]
    },
    otherApps: [
        {
            title: 'Policies',
            description: messages.policiesZeroState,
            link: '/insights/policies'
        },
        {
            title: 'Advisor',
            description: messages.advisorZeroState,
            link: '/insights/advisor'
        }
    ],
    documentation: [
        {
            title: 'Comparing System Configurations and Baselines',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023'
        },
        {
            title: 'Drift - Comparison API',
            link: 'https://console.redhat.com/docs/api/drift'
        },
        {
            title: 'Drift - Baseline API',
            link: 'https://console.redhat.com/docs/api/system-baseline'
        },
        {
            title: 'Configuring notifications & integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const INSIGHTS_ZERO_STATE = {
    header: {
        description: messages.insightsDescription,
        //An array like this would be passed into the app
        commands: [
            {
                intructions: 'Install the client on the RHEL system',
                command: '[root@server] testing install insights-clint'
            },
            {
                intructions: 'Install the client on the RHEL system',
                command: '[root@server] testing install insights-clint'
            },
            {
                intructions: 'Install the client on the RHEL system',
                command: '[root@server] testing install insights-clint'
            }
        ],
        bulletPoints: ['What problems do we solve', 'What solution do we provide']
    },
    otherApps: {}
};

const CONTENT_MANAGEMENT_ZERO_STATE = {
    header: {
        description: 'Red Hat Insights gives you the information to confidently update your RHEL systems with Red Hat product advisories and packages.',
        commands: [
            { plainText: ' 1. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'
            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            }
        ],
        bulletPoints: [
            'View and report on Red Hat product advisories that impact your RHEL environment and apply patches with Ansible Remediation.',
            'Inspect the packages and versions deployed across your RHEL environment.',
            'Add custom repositories and use that content to build customized RHEL images.'
        ]
    },
    otherApps: [
        {
            title: 'Vulnerability',
            description: messages.vulnerabilityZeroState,
            link: '/insights/vulnerability'
        },
        {
            title: 'Advisor',
            description: messages.advisorZeroState,
            link: '/insights/advisor'
        },
        {
            title: 'Image Builder',
            description: messages.imageBuilderZeroState,
            link: '/insights/image-builder'
        }
    ],
    documentation: [
        {
            title: 'System Patching Using Ansible Playbooks',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/system_patching_using_ansible_playbooks_via_remediations'
        },
        {
            title: 'Patch APIs',
            link: 'https://console.redhat.com/docs/api/patch/v2'
        },
        {
            title: 'Configuring notifications & Integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const POLICIES_ZERO_STATE = {
    header: {
        description:
      'Policies allow users to create and manage rule conditions to evaluate against system configuration and get automatically alerted whenever they trigger. It assists in operational management with simple tasks such as:',
        commands: [
            { plainText: ' 1. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'

            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            },
            {
                plainText:
          ' 2. Create condition(s) based on system facts or tags with the help of the wizard'
            }
        ],
        bulletPoints: [
            'Raising an alert when some conditions are met on system configuration',
            'Emailing a team when security packages are out of date on a system',
            'Notifying on Slack when system resources are configured above thresholds',
            'Creating an issue in external ticketing systems when policies are breached',
            'Triggering actions on system inventory automatically'
        ]
    },
    otherApps: [
        {
            title: 'Compliance',
            description: messages.complianceZeroState,
            link: '/insights/compliance'
        },
        {
            title: 'Advisor',
            description: messages.advisorZeroState,
            link: '/insights/advisor'
        },
        {
            title: 'Resource Optimization',
            description: messages.resourceOptimizationZeroState,
            link: '/insights/ros'
        }
    ],
    documentation: [
        {
            title: 'Monitoring and Reacting to Configuration Changes',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/monitoring_and_reacting_to_configuration_changes_using_policies'
        },
        {
            title: 'Policies APIs',
            link: 'https://console.redhat.com/docs/api/policies'
        },
        {
            title: 'Configuring notifications & Integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const MALWARE_ZERO_STATE = {
    header: {
        description: 'The malware detection service monitors your RHEL hosts for known malware signatures to indicate potential threats you can proactively address with your information security team.',
        commands: [
            { instructions: 'Register your RHEL 8+ host', command: 'rhc --register' },
            { instructions: 'Install the yara package', command: 'dnf install yara' },
            {
                instructions: 'Run a malware detection scan',
                command: 'insights-client --collector malware-detection'
            }
        ],
        bulletPoints: [
            'Identify and report on potential malware threats in your RHEL infrastructure.',
            'Access reference information for known Linux malware threats.'
        ]
    },
    otherApps: [
        {
            title: 'Vulnerability',
            description: messages.vulnerabilityZeroState,
            link: '/insights/vulnerability'
        },
        {
            title: 'Compliance',
            description: messages.complianceZeroState,
            link: '/insights/compliance'
        }
    ],
    documentation: [
        {
            title: 'Assessing and Reporting Malware Signatures',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_reporting_malware_signatures_on_rhel_systems_with_the_insights_for_rhel_malware_service'
        }
    ]
};

const RESOURCE_OPTIMIZATION_ZERO_STATE = {
    header: {
        description:
      'Resource Optimization enables users to assess and monitor their public RHEL cloud usage and provides guidance for opportunities for optimization.',
        commands: [
            {
                plainText:
          ' 1. Install & configure Performance Co-Pilot with use for Insights'
            },
            {
                instructions: 'Download Ansible Playbook',
                link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_rhel_resource_optimization_with_insights_for_red_hat_enterprise_linux/assembly-ros-install#installing_resource_optimization_when_ansible_is_already_installed'
            },
            { plainText: 'or' },
            { instructions: 'Complete the manual install', link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_rhel_resource_optimization_with_insights_for_red_hat_enterprise_linux/assembly-ros-install#installing_resource_optimization_without_installing_or_using_ansible' },
            { plainText: '2. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'

            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            },
            {
                plainText:
          'NOTE: After configuration it may take up to 24 hours until suggestions are available'
            }
        ],
        bulletPoints: [
            'Track your system resource utilizations to make better business decisions.',
            'Identify states such as oversized, undersized, idle, or under pressure & made adjustments to optimize.'
        ]
    },
    otherApps: [
        {
            title: 'Advisor',
            description: messages.advisorZeroState,
            link: '/insights/advisor'
        },
        {
            title: 'Drift',
            description: messages.driftZeroState,
            link: '/insights/drift'
        }
    ],
    documentation: [
        {
            title: 'Assessing and Monitoring RHEL Resource Optimization',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_rhel_resource_optimization_with_insights_for_red_hat_enterprise_linux'
        },
        {
            title: 'Resource Optimization APIs',
            link: 'https://console.redhat.com/docs/api/ros'
        },
        {
            title: 'Configuring notifications & Integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

const VULNERABILITY_ZERO_STATE = {
    header: {
        description:
      'Understand the security exposure of your registered RHEL systems and take appropriate steps to protect your organization.',
        commands: [
            { plainText: ' 1. Register your host' },
            {
                instructions: 'RHEL 7',
                command: 'insights-client --register'
            },
            {
                instructions: 'RHEL 8 or newer',
                command: 'rhc --register'
            }
        ],
        bulletPoints: [
            'Identify, triage, and prioritize CVEs affecting your systems.',
            'Generate reports for stakeholders and remediate via Ansible Automation.'
        ]
    },
    otherApps: [
        {
            title: 'Patch',
            description: messages.patchZeroState,
            link: '/insights/patch'
        },
        {
            title: 'Malware',
            description: messages.malwareZeroState,
            link: '/insights/malware'
        },
        {
            title: 'Compliance',
            description: messages.complianceZeroState,
            link: '/insights/compliance'
        }
    ],
    documentation: [
        {
            title: 'Assessing and Monitoring Security Vulnerabilities',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/assessing_and_monitoring_security_vulnerabilities_on_rhel_systems'
        },
        {
            title: 'Generating Vulnerability Service Reports',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_insights/2023/html/generating_vulnerability_service_reports'
        },
        {
            title: 'Vulnerability APIs',
            link: 'https://console.redhat.com/docs/api/vulnerability'
        },
        {
            title: 'Configuring notifications & Integration',
            link: 'https://access.redhat.com/documentation/en-us/red_hat_hybrid_cloud_console/2023/html/configuring_notifications_and_integrations_on_the_red_hat_hybrid_cloud_console/index'
        }
    ]
};

export default {
    ADVISOR_ZERO_STATE,
    COMPLIANCE_ZERO_STATE,
    DRIFT_ZERO_STATE,
    INSIGHTS_ZERO_STATE,
    CONTENT_MANAGEMENT_ZERO_STATE,
    POLICIES_ZERO_STATE,
    MALWARE_ZERO_STATE,
    RESOURCE_OPTIMIZATION_ZERO_STATE,
    VULNERABILITY_ZERO_STATE
};
