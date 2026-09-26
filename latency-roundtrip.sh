#!/usr/bin/env bash
# Netowrk Full Round-Trip (DNS + Transit) Performance Tester

# --- Target Sites ---
declare -A TARGETS=(
    # --- Major Global Platforms ---
    ["Google Search"]="https://google.com"
    ["Reddit"]="https://reddit.com"
    ["GitHub"]="https://github.com"
    ["Wikipedia"]="https://wikipedia.org"
)

echo "========================================================="
echo "       FULL ROUND-TRIP NETWORK PERFORMANCE TESTER"
echo "========================================================="
echo "Timestamp : $(date)"
echo "---------------------------------------------------------"
printf "%-22s | %-14s | %-14s\n" "Destination" "DNS Resolution" "Total Connect"
echo "---------------------------------------------------------"

# Custom curl format string to extract high-resolution timing metrics
CURL_FORMAT='{"dns":"%{time_namelookup}s", "total":"%{time_connect}s"}\n'

for site in "${!TARGETS[@]}"; do
    url="${TARGETS[$site]}"
    
    # Execute a lightweight HEAD request, bypassing the actual page download body
    result=$(curl -s -I -o /dev/null -w "$CURL_FORMAT" --connect-timeout 4 "$url" 2>/dev/null)
    
    if [ -n "$result" ]; then
        # Parse out the metrics safely using standard bash string manipulation
        dns_time=$(echo "$result" | grep -o '"dns":"[^"]*' | cut -d'"' -f4)
        total_time=$(echo "$result" | grep -o '"total":"[^"]*' | cut -d'"' -f4)
        
        # Format the output so it looks exactly like crisp terminal metrics
        printf "%-22s | %-11ss | %-11ss\n" "$site" "$dns_time" "$total_time"
    else
        printf "%-22s | %-14s | %-14s\n" "$site" "FAILED/TIMEOUT" "FAILED/TIMEOUT"
    fi
done
echo "========================================================="
