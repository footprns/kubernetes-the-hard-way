{% from "files/map.jinja" import etcd_servers %}

install etcd binary:
  archive.extracted:
    - name: /tmp
    - source: https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz
    - skip_verify: True

{% for item in ['etcd', 'etcdctl'] %}
copy {{ item }} to bin directory:
  file.managed:
    - name: /usr/local/bin/{{ item }}
    - source: /tmp/etcd-v3.3.9-linux-amd64/{{ item }}
    - mode: 755
{% endfor %}

{% for item in ['/etc/etcd', '/var/lib/etcd'] %}
create etcd {{ item }} directory:
  file.directory:
    - name: {{ item }}
{% endfor %}

{% for item in ['ca.crt', 'etcd-server.key', 'etcd-server.crt'] %}
copy certificate {{ item }} for etcd:
  file.managed:
    - name: /etc/etcd/{{ item }}
    - source: salt://files/{{ item }}
{% endfor %}

put etcd service file:
  file.managed:
    - name: /etc/systemd/system/etcd.service
    - source: salt://files/etcd.service.jinja
    - template: jinja
    - ETCD_NAME: {{ grains['id'] }}
    - INTERNAL_IP: {{ grains['ip4_interfaces']['eth0']|join('') }}
    - etcd_servers: {{ etcd_servers }}

reload service etcd:
  cmd.run:
    - name: sudo systemctl daemon-reload

run service:
  service.running:
    - name: etcd
    - enable: True
    - watch:
      - file: put etcd service file