{% from "files/map.jinja" import etcd_servers, cluster_conf %}

create certificate for master:
  cmd.run:
    - name: |
        # Create a CA certificate
        openssl genrsa -out ca.key 2048
        openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
        openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000

        # Admin Client Certificate
        openssl genrsa -out admin.key 2048
        openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
        openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000

        # The Controller Manager Client Certificate
        openssl genrsa -out kube-controller-manager.key 2048
        openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
        openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 1000

        # The Kube Proxy Client Certificate
        openssl genrsa -out kube-proxy.key 2048
        openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
        openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-proxy.crt -days 1000

        # The Scheduler Client Certificate
        openssl genrsa -out kube-scheduler.key 2048
        openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
        openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-scheduler.crt -days 1000

        # The Kubernetes API Server Certificate
        cat > openssl.cnf <<EOF
        [req]
        req_extensions = v3_req
        distinguished_name = req_distinguished_name
        [req_distinguished_name]
        [ v3_req ]
        basicConstraints = CA:FALSE
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        subjectAltName = @alt_names
        [alt_names]
        DNS.1 = kubernetes
        DNS.2 = kubernetes.default
        DNS.3 = kubernetes.default.svc
        DNS.4 = kubernetes.default.svc.cluster.local
        IP.1 = 127.0.0.1
        IP.2 = {{ cluster_conf['LOADBALANCER_ADDRESS'] }}
        IP.3 = 10.96.0.1
        {% for item in etcd_servers -%}
        IP.{{ loop.index + 3 }} = {{ etcd_servers[item]['ip'] }}
        {% endfor %}
        EOF
        openssl genrsa -out kube-apiserver.key 2048
        openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr -config openssl.cnf
        openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000

        # The ETCD Server Certificate
        cat > openssl-etcd.cnf <<EOF
        [req]
        req_extensions = v3_req
        distinguished_name = req_distinguished_name
        [req_distinguished_name]
        [ v3_req ]
        basicConstraints = CA:FALSE
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        subjectAltName = @alt_names
        [alt_names]
        IP.1 = 127.0.0.1
        IP.2 = {{ cluster_conf['LOADBALANCER_ADDRESS'] }}
        {% for item in etcd_servers -%}
        IP.{{ loop.index + 2 }} = {{ etcd_servers[item]['ip'] }}
        {% endfor %}
        EOF
        openssl genrsa -out etcd-server.key 2048
        openssl req -new -key etcd-server.key -subj "/CN=etcd-server" -out etcd-server.csr -config openssl-etcd.cnf
        openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000

        # The Service Account Key Pair
        openssl genrsa -out service-account.key 2048
        openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
        openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 1000
    - cwd: {{ cluster_conf['working_directory'] }}/files

create kubeconfig for master:
  cmd.run:
    - name: |
        LOADBALANCER_ADDRESS={{ cluster_conf['LOADBALANCER_ADDRESS'] }}
        # The kube-proxy Kubernetes Configuration File
        kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://${LOADBALANCER_ADDRESS}:6443 \
        --kubeconfig=kube-proxy.kubeconfig

        kubectl config set-credentials system:kube-proxy \
        --client-certificate=kube-proxy.crt \
        --client-key=kube-proxy.key \
        --embed-certs=true \
        --kubeconfig=kube-proxy.kubeconfig

        kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-proxy \
        --kubeconfig=kube-proxy.kubeconfig

        kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

        # The kube-controller-manager Kubernetes Configuration File
        kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=kube-controller-manager.kubeconfig

        kubectl config set-credentials system:kube-controller-manager \
        --client-certificate=kube-controller-manager.crt \
        --client-key=kube-controller-manager.key \
        --embed-certs=true \
        --kubeconfig=kube-controller-manager.kubeconfig

        kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-controller-manager \
        --kubeconfig=kube-controller-manager.kubeconfig

        kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

        # The kube-scheduler Kubernetes Configuration File
        kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=kube-scheduler.kubeconfig

        kubectl config set-credentials system:kube-scheduler \
        --client-certificate=kube-scheduler.crt \
        --client-key=kube-scheduler.key \
        --embed-certs=true \
        --kubeconfig=kube-scheduler.kubeconfig

        kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:kube-scheduler \
        --kubeconfig=kube-scheduler.kubeconfig

        kubectl config use-context default \
        --kubeconfig=kube-scheduler.kubeconfig

        # The admin Kubernetes Configuration File
        kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://127.0.0.1:6443 \
        --kubeconfig=admin.kubeconfig

        kubectl config set-credentials admin \
        --client-certificate=admin.crt \
        --client-key=admin.key \
        --embed-certs=true \
        --kubeconfig=admin.kubeconfig

        kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=admin \
        --kubeconfig=admin.kubeconfig

        kubectl config use-context default \
        --kubeconfig=admin.kubeconfig
    - cwd: {{ cluster_conf['working_directory'] }}/files
    - require: 
        - cmd: create certificate for master
{#
{% load_yaml as cert_properties %}
admin:
  subj: /CN=admin/O=system:masters
kube-controller-manager:
  subj: /CN=system:kube-controller-manager
kube-proxy:
  subj: /CN=system:kube-proxy
kube-scheduler:
  subj: /CN=system:kube-scheduler
kube-apiserver.key:
  subj: /CN=kube-apiserver
  config: openssl.cnf
  alt_names:
    - DNS.1 = kubernetes
    - DNS.2 = kubernetes.default
    - DNS.3 = kubernetes.default.svc
    - DNS.4 = kubernetes.default.svc.cluster.local
    - IP.1 = 127.0.0.1
    - IP.2 = {{ cluster_conf['LOADBALANCER_ADDRESS'] }}
    {% for item in etcd_servers %}
    - IP.{{ loop.index + 2 }} = {{ etcd_servers[item]['ip'] }}
    {% endfor %}
etcd-server:
  subj: /CN=etcd-server
  config: openssl-etcd.cnf
  alt_names:
    - IP.1 = 127.0.0.1
    {% for item in etcd_servers %}
    - IP.{{ loop.index + 1 }} = {{ etcd_servers[item]['ip'] }}
    {% endfor %}
service-account:
  subj: /CN=service-accounts
{% endload %}

{% for item in cert_properties %}
{% if cert_properties[item]['config'] is defined %}
create cert config {{ item }}:
  file.managed:
    - name: '{{ cluster_conf['working_directory'] }}/files/{{ cert_properties[item]['config'] }}'
    - contents: |
        [req]
        req_extensions = v3_req
        distinguished_name = req_distinguished_name
        [req_distinguished_name]
        [ v3_req ]
        basicConstraints = CA:FALSE
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        subjectAltName = @alt_names
        [alt_names]
        {% for alt_names in cert_properties[item]['alt_names'] -%}
        {{ alt_names }}
        {% endfor %}
{% endif %}
{% endfor %}

create root ca:
  cmd.run:
    - name: |
        openssl genrsa -out ca.key 2048
        openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
        openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
    - cwd: {{ cluster_conf['working_directory'] }}/files

{% for item in cert_properties %}
create {{ item }} cert:
  cmd.run:
    - name: |
        openssl genrsa -out {{ item }}.key 2048
        openssl req -new -key {{ item }}.key -subj "{{ cert_properties[item]['subj'] }}" -out {{ item }}.csr {% if cert_properties[item]['config'] is defined %}-config {{ cert_properties[item]['config'] }}{% endif %}
        openssl x509 -req -in {{ item }}.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out {{ item }}.crt -days 1000 {% if cert_properties[item]['config'] is defined %}-extensions v3_req -extfile {{ cert_properties[item]['config'] }}{% endif %}
    - cwd: {{ cluster_conf['working_directory'] }}/files
{% endfor %}
#}