#!/bin/sh
set -e

# Opt-in slash command deployment on container start (set DEPLOY_COMMANDS=true in env)
if [ "$DEPLOY_COMMANDS" = "true" ]; then
    echo "DEPLOY_COMMANDS=true -> running setup.js to deploy slash commands..."
    node setup.js
fi

exec "$@"
