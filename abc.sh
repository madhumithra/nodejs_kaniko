pwd && ls -l && df -h && cat /kaniko/.docker/config.json && /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=localhost:5000:5.1
