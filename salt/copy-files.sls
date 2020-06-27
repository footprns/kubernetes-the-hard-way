{% for item in ['ca.crt', 'ca.key', 'kube-apiserver.key', 'kube-apiserver.crt', 'service-account.key', 'service-account.crt', 'etcd-server.key', 'etcd-server.crt'] %}
copy kubectl certificate {{ item }} file:
  file.managed:
    - name: /home/ubuntu/{{ item }}
    - source : salt://files/{{ item }}
{% endfor %}

{% for item in ['admin.crt', 'admin.key'] %}
copy kubectl certificate {{ item }} file:
  file.managed:
    - name: /home/ubuntu/{{ item }}
    - source : salt://files/{{ item }}
{% endfor %}

{% for item in ['kube-proxy.kubeconfig', 'admin.kubeconfig', 'kube-controller-manager.kubeconfig', 'kube-scheduler.kubeconfig'] %}
copy kubectl config {{ item }} file:
  file.managed:
    - name: /home/ubuntu/{{ item }}
    - source : salt://files/{{ item }}
{% endfor %}