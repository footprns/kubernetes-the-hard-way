{% from "files/map.jinja" import worker_servers %}
change hostname:
  module.run:
    - name: system.set_computer_name
    - hostname: {{ grains['id'] }}

add host entry for worker:
  file.append:
    - name: /etc/hosts
    - text: |
        {% for item in worker_servers -%}
        {{ worker_servers[item]['ip'] }} {{ worker_servers[item]['host'] }}
        {% endfor %}