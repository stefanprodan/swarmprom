route:
    receiver: 'slack'

receivers:
    - name: 'slack'
      slack_configs:
          - send_resolved: true
            text: "{{ .CommonAnnotations.description }}"
            #username: <user>#
            #channel: <channel>#
            #api_url: <url>#
