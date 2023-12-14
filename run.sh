#!/bin/bash

export PYTHONPATH=$(pwd)

# Function to gracefully terminate processes
terminate_processes() {
    echo "Terminating processes..."
    pkill -P $$  # Kill child processes
    tmux kill-session -t mysession  # Kill tmux session
    exit
}

# Trap Ctrl+C (SIGINT) signal to call the termination function
trap terminate_processes INT

# Start a tmux session for FastAPI
tmux new-session -d -s mysession "python -u app/main.py"

# Start RabbitMQ consumers
for i in {1..4}; do
    python -u inference_workers/workers.py &
done

# Store PIDs of RabbitMQ consumers
rabbitmq_pids=$(jobs -p)

# Wait for RabbitMQ consumers to finish
wait $rabbitmq_pids

# Terminate processes on script exit
terminate_processes
