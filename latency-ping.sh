#!/usr/bin/env bash
# Network Latency Tester

# --- Target Sites (Grouped by Type) ---
declare -A TARGETS=(
    # --- Global Anycast / Infrastructure (Should always be fastest) ---
    ["Cloudflare DNS (1.1.1.1)"]="1.1.1.1"
    ["Google DNS (8.8.8.8)"]="8.8.8.8"
    ["Quad9 DNS (9.9.9.9)"]="9.9.9.9"

    # --- Major Global Platforms ---
    ["Google Search"]="google.com"
    ["Reddit"]="reddit.com"
    ["GitHub"]="github.com"
    ["Wikipedia"]="wikipedia.org"
)

# Number of pings per site for an accurate average
PING_COUNT=4

echo "==============================================="
echo "   NETOWORK LATENCY & ROUTING IMPACT TESTER"
echo "==============================================="
echo "Timestamp : $(date)"
echo "Ping Count: $PING_COUNT requests per destination"
echo "-----------------------------------------------"
printf "%-30s | %-12s\n" "Destination" "Avg Latency"
echo "-----------------------------------------------"

# Loop through the targets
for site in "${!TARGETS[@]}"; do
    host="${TARGETS[$site]}"
    
    # Run ping, extract the average RTT using awk
    # Works across standard Linux and Android/Termux ping binaries
    avg_latency=$(ping -c "$PING_COUNT" -q "$host" 2>/dev/null | awk -F '/' '/rtt|mdev/ {print $5}')
    
    if [ -n "$avg_latency" ]; then
        printf "%-30s | %-6s ms\n" "$site" "$avg_latency"
    else
        printf "%-30s | %-12s\n" "$site" "FAILED/TIMEOUT"
    fi
done
echo "==============================================="
