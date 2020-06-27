{% from "files/map.jinja" import cluster_conf, worker_servers, etcd_servers %}

copy ca file:
  file.managed:
    - name: /home/ubuntu/ca.crt
    - source: salt://files/ca.crt

{% for ext in ['.crt', '.key', '.kubeconfig'] %}
copy {{ grains['id'] }}{{ ext }}:
  file.managed:
    - name: /home/ubuntu/{{ grains['id'] }}{{ ext }}
    - source: salt://files/{{ grains['id'] }}{{ ext }}
{% endfor %}

{% for item in ['/etc/cni/net.d', '/opt/cni/bin', '/var/lib/kubelet', '/var/lib/kube-proxy', '/var/lib/kubernetes', '/var/run/kubernetes'] %}
create {{ item }}:
  file.directory:
    - name: {{ item }}
    - makedirs: True
{% endfor %}

{% for item in ['kubelet', 'kube-proxy', 'kubectl'] %}
install worker binaries {{ item }}:
  file.managed:
    - name: /usr/local/bin/{{ item }}
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/{{ item }}
    - skip_verify: True
    - mode: 755
{% endfor %}

{% for ext in ['.key', '.crt'] %}
config copy certificate {{ grains['id'] }}{{ ext }}:
  file.managed:
    - name: /var/lib/kubelet/{{ grains['id'] }}{{ ext }}
    - source: salt://files/{{ grains['id'] }}{{ ext }}
{% endfor %}

copy kubeconfig:
  file.managed:
    - name: /var/lib/kubelet/kubeconfig
    - source: salt://files/{{ grains['id'] }}.kubeconfig

copy ca final file:
  file.managed:
    - name: /var/lib/kubernetes/ca.crt
    - source: salt://files/ca.crt

put yaml file:
  file.managed:
    - name: /var/lib/kubelet/kubelet-config.yaml
    - source: salt://files/kubelet-config.yaml

put worker service file:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source: salt://files/kubelet.service.jinja
    - template: jinja
    - HOSTNAME: {{ grains['id'] }}
  service.running:
    - name: kubelet
    - enable: True
    - watch:
        - file: copy kubeconfig
        {% for ext in ['.key', '.crt'] -%}
        - file: config copy certificate {{ grains['id'] }}{{ ext }}
        {% endfor %}
        {#{% for item in ['10-mynet.conf', '99-loopback.conf'] -%}
        - file: cni configuration file {{ item }}
        {% endfor %}#}

{# kube-proxy #}
put kube-proxy configuration:
  file.managed:
    - name: /var/lib/kube-proxy/kubeconfig
    - source: salt://files/kube-proxy.kubeconfig

put kube-proxy-config configuration:
  file.managed:
    - name: /var/lib/kube-proxy/kube-proxy-config.yaml
    - source: salt://files/kube-proxy-config.yaml.jinja
    - template: jinja
    - clusterCIDR: {{ cluster_conf['clusterCIDR'] }}

put kube-proxy service:
  file.managed:
    - name: /etc/systemd/system/kube-proxy.service
    - source: salt://files/kube-proxy.service.jinja

run kube-proxy service:
  service.running:
    - name: kube-proxy
    - enable: True
    - watch:
        - file: put kube-proxy configuration
        - file: put kube-proxy-config configuration
        - file: put kube-proxy service
        {#{% for item in ['10-mynet.conf', '99-loopback.conf'] -%}
        - file: cni configuration file {{ item }}
        {% endfor %}#}

install cni plugins binary:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/v0.7.5/cni-plugins-amd64-v0.7.5.tgz
    - skip_verify: True

{#{% for item in ['10-mynet.conf', '99-loopback.conf'] %}
cni configuration file {{ item }}:
  file.managed:
    - name: /etc/cni/net.d/{{ item }}
    - source: salt://files/{{ item }}
{% endfor %}#}



