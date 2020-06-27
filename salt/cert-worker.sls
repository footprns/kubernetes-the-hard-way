{% from "files/map.jinja" import worker_servers, cluster_conf %}

{% for item in worker_servers %}
create cert config {{ item }}:
  file.managed:
    - name: '{{ cluster_conf['working_directory'] }}/files/openssl-{{ item }}.cnf'
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
        DNS.1 = {{ worker_servers[item]['host'] }}
        IP.1 = {{ worker_servers[item]['ip'] }}
  cmd.run:
    - name: |
        openssl genrsa -out {{ item }}.key 2048
        openssl req -new -key {{ item }}.key -subj "/CN=system:node:{{ item }}/O=system:nodes" -out {{ item }}.csr -config openssl-{{ item }}.cnf
        openssl x509 -req -in {{ item }}.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out {{ item }}.crt -extensions v3_req -extfile openssl-{{ item }}.cnf -days 1000

        kubectl config set-cluster {{ cluster_conf['cluster'] }} \
        --certificate-authority=ca.crt \
        --embed-certs=true \
        --server=https://{{ cluster_conf['LOADBALANCER_ADDRESS'] }}:6443 \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config set-credentials system:node:{{ item }} \
        --client-certificate={{ item }}.crt \
        --client-key={{ item }}.key \
        --embed-certs=true \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config set-context default \
        --cluster={{ cluster_conf['cluster'] }} \
        --user=system:node:{{ item }} \
        --kubeconfig={{ item }}.kubeconfig

        kubectl config use-context default \
        --kubeconfig={{ item }}.kubeconfig
    - cwd: {{ cluster_conf['working_directory'] }}/files
{% endfor %}

