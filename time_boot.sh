#!/bin/bash

SERIAL_LOG=fc-serial.log

# Start Firecracker in the background, logging serial output
rm -f $SERIAL_LOG
start_time=$(date +%s.%N)
firecracker --api-sock /tmp/firecracker.socket > $SERIAL_LOG 2>&1 &

# Wait for the VM to output "login:" (or another known string)
while ! grep -q "login:" $SERIAL_LOG; do
    sleep 0.1
done

end_time=$(date +%s.%N)
boot_time=$(echo "$end_time - $start_time" | bc)
echo "Boot time: $boot_time seconds"
