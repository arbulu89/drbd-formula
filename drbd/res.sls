{%- from "drbd/map.jinja" import drbd with context -%}

{% for res in drbd.resource %}
{% set nodeid = 1 %}
/etc/drbd.d/{{ res.name }}.res:
  file.managed:
    - source: salt://drbd/templates/{{ drbd.res_template }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        name: '{{ res.name }}'
        device: '{{ res.device }}'
{% if res.disk is defined %}
        disk: '{{ res.disk }}'
{% endif %}

        meta_disk: '{{ res.meta_disk|default("internal") }}'
        protocol:  '{{ res.protocol|default("C") }}'
        ping_timeout: {{ res.ping_timeout|default(10) }}
        on_io_error: '{{ res.on_io_error|default("pass_on") }}'

        fixed_rate: {{ res.fixed_rate|default(True) }}
        resync_rate: '{{ res.resync_rate|default("100M") }}'
        c_plan_ahead: {{ res.c_plan_ahead|default(20) }}
        c_delay_target: '{{ res.c_delay_target|default(1) }}'
        c_fill_target: '{{ res.c_fill_target|default("10M") }}'
        c_max_rate: '{{ res.c_max_rate|default("100M") }}'
        c_min_rate: '{{ res.c_min_rate|default("4M") }}'

        # To concate string with number, need to use join. Like
        # name: '{{ ["drbd-node", loop.index + 1]|join('') }}'
        nodes:
          - name: "drbd-node1"
            ip: "192.168.10.101"
            port: {{ 7980 + loop.index0 * 2 }}
            id: {{ nodeid }}
          - name: "drbd-node2"
            ip: "192.168.10.102"
            port: {{ 7980 + loop.index0 * 2 }}
            id: {{ nodeid + 1 }}

{% if res.nodes is defined and res.nodes|length > 0 %}
    - context:
        nodes: {{ res.nodes|json }}
{% endif %}
{% endfor %}
