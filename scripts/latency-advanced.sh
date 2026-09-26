#!/usr/bin/env bash
# Deep Network Latency Breakdown (Fixed Header Output)

# --- Target Sites ---
declare -A TARGETS=(
    # --- Major Global Platforms ---
    ["Google Search"]="https://google.com"
    ["Reddit"]="https://reddit.com"
    ["GitHub"]="https://github.com"
    ["Wikipedia"]="https://wikipedia.org"
)

echo "========================================================="
echo "        ADVANCED NETWORK LAYER PERFORMANCE TESTER"
echo "========================================================="
echo "Timestamp : $(date)"

for site in "${!TARGETS[@]}"; do
    url="${TARGETS[$site]}"
    
    # Building the header block cleanly into the format variable dynamically
    CURL_FORMAT="
--------------------------------------------
 $site
--------------------------------------------
 DNS Lookup Time   : %{time_namelookup}s
 TCP Handshake     : %{time_connect}s
 TLS Key Exchange  : %{time_appconnect}s
 Server Think Time : %{time_starttransfer}s
 Total Transaction : %{time_total}s\n"
    
    # Run curl purely against the URL with our dynamic formatting template
    curl -s -o /dev/null -w "$CURL_FORMAT" --connect-timeout 4 "$url" 2>/dev/null
done
echo "========================================================="
