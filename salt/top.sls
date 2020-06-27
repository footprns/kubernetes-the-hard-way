base:
  '*':
    - change-hostname
  'master*':
    - docker
    - etcd
    - control-plane
    - copy-files
  'haproxy':
    - haproxy
  'worker*':
    - docker
    - worker