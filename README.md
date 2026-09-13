# network-performance-testers
linux network performance testers

## Features
* Network Full Round-Trip (DNS + Transit) Performance Tester
* Network Latency Tester
* Network Latency Breakdown

### Network Full Round-Trip (DNS + Transit) Performance Tester
```bash
nano latency.roundtrip.sh
```
```ini
#!/usr/bin/env bash
# Network Full Round-Trip (DNS + Transit) Performance Tester

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

```
Printout example
```ini
=========================================================
       FULL ROUND-TRIP NETWORK PERFORMANCE TESTER
=========================================================
---------------------------------------------------------
Destination            | DNS Resolution | Total Connect 
---------------------------------------------------------
Reddit                 | 0.000584s  s | 0.002400s  s
GitHub                 | 0.000519s  s | 0.025737s  s
Google Search          | 0.000632s  s | 0.015769s  s
Wikipedia              | 0.000534s  s | 0.024306s  s
=========================================================

```
### Network Latency Tester
```bash
nano latency.ping.sh
```
```ini
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
echo "   NETWORK LATENCY & ROUTING IMPACT TESTER"
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

```
Printout example
```ini
===============================================
   NETWORK LATENCY & ROUTING IMPACT TESTER
===============================================
Ping Count: 4 requests per destination
-----------------------------------------------
Destination                    | Avg Latency 
-----------------------------------------------
Cloudflare DNS (1.1.1.1)       | 1.812  ms
Quad9 DNS (9.9.9.9)            | 8.414  ms
Reddit                         | 1.779  ms
GitHub                         | 25.165 ms
Google DNS (8.8.8.8)           | 7.857  ms
Google Search                  | 15.716 ms
Wikipedia                      | 23.607 ms
===============================================

```
### Network Latency Breakdown
```bash
nano latency.advanced.sh
```
```ini
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
    
    # We build the header block cleanly into the format variable dynamically
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

```
Printout example
```ini
=========================================================
        ADVANCED NETWORK LAYER PERFORMANCE TESTER
=========================================================
--------------------------------------------
 Reddit
--------------------------------------------
 DNS Lookup Time   : 0.000603s
 TCP Handshake     : 0.002509s
 TLS Key Exchange  : 0.025667s
 Server Think Time : 0.028377s
 Total Transaction : 0.028401s

--------------------------------------------
 GitHub
--------------------------------------------
 DNS Lookup Time   : 0.058692s
 TCP Handshake     : 0.083911s
 TLS Key Exchange  : 0.113016s
 Server Think Time : 0.140020s
 Total Transaction : 0.267743s

--------------------------------------------
 Google Search
--------------------------------------------
 DNS Lookup Time   : 0.000486s
 TCP Handshake     : 0.015293s
 TLS Key Exchange  : 0.043206s
 Server Think Time : 0.073199s
 Total Transaction : 0.073251s

--------------------------------------------
 Wikipedia
--------------------------------------------
 DNS Lookup Time   : 0.000496s
 TCP Handshake     : 0.025653s
 TLS Key Exchange  : 0.056960s
 Server Think Time : 0.081953s
 Total Transaction : 0.082008s
 
=========================================================
```

---

## 📄 License

This project is open-source and licensed under the **MIT License**. Feel free to use, modify, and distribute it as you see fit. See the accompanying `LICENSE` file for full legal details.

