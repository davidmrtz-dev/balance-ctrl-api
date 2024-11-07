#!/bin/bash

# Open a new iTerm2 window for ngrok
echo "Starting ngrok in a new iTerm2 window..."
osascript <<EOF
tell application "iTerm2"
    create window with default profile
    tell current session of current window
        write text "ngrok http --url=gannet-trusted-ray.ngrok-free.app 3006"
    end tell
end tell
EOF

# Open another iTerm2 window for docker-compose up --build
echo "Starting docker-compose up --build in a new iTerm2 window..."
osascript <<EOF
tell application "iTerm2"
    create window with default profile
    tell current session of current window
        write text "docker-compose up --build"
    end tell
end tell
EOF

echo "Waiting for the API to be ready at the health endpoint..."

# Function to check the health endpoint status
check_health() {
    status_code=$(curl -s -o /dev/null -w "%{http_code}" https://gannet-trusted-ray.ngrok-free.app/health)
    if [ "$status_code" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Wait until the health check returns 200
until check_health; do
    echo "The API is not ready yet. Waiting 5 seconds before checking again..."
    sleep 5
done

echo "The API is ready."

# Run db:truncate_all
echo "Running db:truncate_all..."
docker exec -it balance-ctrl-api-rails_app-1 rails db:truncate_all

# Run db:seed:all
echo "Running db:seed:all..."
docker exec -it balance-ctrl-api-rails_app-1 rails db:seed:all

echo "Initialization complete."
