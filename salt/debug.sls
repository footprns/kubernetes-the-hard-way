{% from "files/map.jinja" import etcd_servers %}
debug01:
  test.nop:
    - name: __{% for item in etcd_servers %}{{ etcd_servers[item]['ip'] }}{% endfor %}__