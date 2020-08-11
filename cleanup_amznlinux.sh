#!/bin/bash
function uninstall_elasticsearch(){
    sudo systemctl kill elasticsearch \
    && sudo yum remove elasticsearch -y \
    && sudo rm -f /etc/yum.repos.d/elasticsearch.repo \
    && echo "Elasticsearch uninstalled"
}
function unstall_filebeat(){
    sudo systemctl kill filebeat \
    && sudo yum remove filebeat -y \
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