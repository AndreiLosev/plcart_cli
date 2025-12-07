const systemdService = """
[Unit]
Description={{ Description }}
After=network-online.target mosquitto.service
Wants=network-online.target
Requires=network.target
Requires=mosquitto.service

[Service]
Type=simple
ExecStart={{ ExecStart }}
Restart=always
RestartSec=2
StartLimitIntervalSec=0

# Ожидание готовности Mosquitto (опционально, но рекомендуется)
ExecStartPre=/bin/sleep 1
ExecStartPre=/bin/bash -c 'until systemctl is-active --quiet mosquitto.service; do sleep 1; done'

# Логирование
StandardOutput=journal
StandardError=journal
SyslogIdentifier={{ SyslogIdentifier }}

# Безопасность
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/lib/{{ SyslogIdentifier }}/data
ProtectHome=true

[Install]
WantedBy=multi-user.target
""";
