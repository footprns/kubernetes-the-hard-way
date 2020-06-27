{% from "files/map.jinja" import etcd_servers %}
update repo:
  pkg.uptodate:
    - refresh: True

haproxy configuration:
  file.managed:
    - name: /tmp/haproxy.cfg
    - source: salt://files/haproxy.cfg.jinja
    - template: jinja
    - internal_ip: {{ grains['ip4_interfaces']['eth0']|join('') }}
    - etcd_servers: {{ etcd_servers }}

install haproxy:
  pkg.installed:
    - name: haproxy
  file.append:
    - name: /etc/haproxy/haproxy.cfg
    - source: /tmp/haproxy.cfg
  service.running:
    - name: haproxy
    - enable: True
    - watch:
        - file: install haproxy