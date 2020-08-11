#!/bin/bash
function uninstall_elasticsearch(){
    sudo systemctl kill elasticsearch \
    && sudo apt-get remove --purge elasticsearch -y \
    && wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key del - \
    && sudo rm -f /etc/apt/sources.list.d/elastic-7.x.list \
    && echo "Elasticsearch uninstalled"
}
function unstall_filebeat(){
    sudo systemctl kill filebeat \
    && sudo dpkg --remove filebeat \
    && sudo rm -rf filebeat-*-amd64.deb \
    && echo "Filebeat uninstalled"
}
function clean_logs(){
    sudo rm -rf /var/log/app1_beat*.log /var/log/app2_beat*.log
}
set -x \
&& unstall_filebeat \
&& uninstall_elasticsearch \
&& clean_logs \
&& echo "Cleanup Complete" \
&& set +x