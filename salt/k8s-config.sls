{% from "files/map.jinja" import cluster_conf %}

{% load_yaml as kubeconfig_files %}
kube-proxy:
  server: {{ cluster_conf['LOADBALANCER_ADDRESS'] }}
kube-controller-manager:
  server: 127.0.0.1
kube-scheduler:
  server: 127.0.0.1
admin:
  server: 127.0.0.1
{% endload %}

{% for item in kubeconfig_files %}
create {{ item }}.kubeconfig:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ cluster_conf['cluster'] }} \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://{{ cluster_conf['LOADBALANCER_ADDRESS'] }}:6443 \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config set-credentials system:{{ item }} \
        --client-certificate={{ item }}.crt \
        --client-key={{ item }}.key \
        --embed-certs=true \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config set-context default \
        --cluster={{ cluster_conf['cluster'] }} \
        --user=system:{{ item }} \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config use-context default \
        --kubeconfig={{ item }}.kubeconfig
    - cwd: {{ cluster_conf['working_directory'] }}/files
{% endfor %}