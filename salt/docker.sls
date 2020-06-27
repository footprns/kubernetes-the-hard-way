{% from "files/map.jinja" import docker_pkgs %}

add repo key:
  module.run:
    - name: pkg.add_repo_key
    - path: https://download.docker.com/linux/ubuntu/gpg

add docker repo:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable

update repo:
  pkg.uptodate:
    - refresh: True

{% for item in docker_pkgs %}
install {{ item }}:
  pkg.installed:
    - name: {{ item }}
{% endfor %}

