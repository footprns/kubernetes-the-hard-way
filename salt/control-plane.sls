{% from "files/map.jinja" import etcd_servers, kubeapi_certificates %}

{% for item in ['/etc/kubernetes/config', '/var/lib/kubernetes'] %}
create {{ item }} directory:
  file.directory:
    - name: {{ item }}
    - makedirs: True
{% endfor %}

{% for item in ['kube-apiserver', 'kube-controller-manager', 'kube-scheduler', 'kubectl'] %}
install kubernetes control plane binary {{ item }}:
  file.managed:
    - name: /usr/local/bin/{{ item }}
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/{{ item }}
    - skip_verify: True
    - mode: 755
{% endfor %}

{% for item in kubeapi_certificates %}
copy certificate {{ item }} file:
  file.managed:
    - name: /var/lib/kubernetes/{{ item }}
    - source: salt://files/{{ item }}
{% endfor %}

reload service:
  cmd.run:
    - name: sudo systemctl daemon-reload

put service file:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://files/kube-apiserver.service.jinja
    - template: jinja
    - INTERNAL_IP: {{ grains['ip4_interfaces']['eth0']|join('') }}
    - etcd_servers: {{ etcd_servers }}
  service.running:
    - name: kube-apiserver
    - enable: True
    - watch:
        - file: put service file
        {% for item in kubeapi_certificates %}
        - file: copy certificate {{ item }} file
        {% endfor %}

put kube-controller-manager:
  file.managed:
    - name: /var/lib/kubernetes/kube-controller-manager.kubeconfig
    - source: salt://files/kube-controller-manager.kubeconfig

put Kubernetes Controller Manager service file:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://files/kube-controller-manager.service.jinja
    - template: jinja
    - cluster_cidr: 172.31.0.0/20
  service.running:
    - name: kube-controller-manager
    - enable: True
    - watch:
        - file: put Kubernetes Controller Manager service file
        {% for item in kubeapi_certificates %}
        - file: copy certificate {{ item }} file
        {% endfor %}

put kube-scheduler:
  file.managed:
    - name: /var/lib/kubernetes/kube-scheduler.kubeconfig
    - source: salt://files/kube-scheduler.kubeconfig

put kube-scheduler service file:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://files/kube-scheduler.service.jinja
  service.running:
    - name: kube-scheduler
    - enable: True
    - watch:
        - file: put kube-scheduler service file
        {% for item in kubeapi_certificates %}
        - file: copy certificate {{ item }} file
        {% endfor %}
{#
reload service:
  cmd.run:
    - name: sudo systemctl daemon-reload

{% for item in ['kube-apiserver', 'kube-controller-manager', 'kube-scheduler'] %}
running {{ item }} service:
  service.running:
    - name: {{ item }}
    - enable: True
{% endfor %}

#}
