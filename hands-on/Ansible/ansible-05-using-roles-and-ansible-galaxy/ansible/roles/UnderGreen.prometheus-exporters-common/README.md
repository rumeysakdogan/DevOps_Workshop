# Ansible Role: prometheus-exporters-common

An Ansible role that installs Prometheus Monitoring server on Ubuntu-based machines with systemd.

## Requirements

All needed packages will be installed with this role.

## Role Variables

Available variables are listed below, along with default values:
```yaml
prometheus_exporters_common_user: prometheus
prometheus_exporters_common_group: prometheus

prometheus_exporters_common_root_dir: /opt/prometheus/exporters
prometheus_exporters_common_dist_dir: "{{ prometheus_exporters_common_root_dir }}/dist"
prometheus_exporters_common_conf_dir: "/etc/prometheus/exporters"
```
## Dependencies

This role doesn't have dependencies.

## License

GPLv2
