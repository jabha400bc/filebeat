#!/bin/bash
# Define Functions
##########################################################################################
# Function to Install Elasticsearch
# Refer: https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
function install_elasticsearch(){
    # 1. Download and install the public signing key
    # 2. Install the apt-transport-https package on Debian before proceeding
    # 3. Save the repository definition to /etc/apt/sources.list.d/elastic-7.x.list
    # 4. Install the Elasticsearch Debian package.
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch \
    && get_yum_repo | sudo tee /etc/yum.repos.d/elasticsearch.repo \
    && sudo yum install --enablerepo=elasticsearch elasticsearch -y
}
function get_yum_repo(){
cat << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
}
# Function to Take a backup of ES's config yaml because we will be changing the http.host
function backup_es_yml(){
    # 1. First check if elasticsearch_bkup.yml already exists.
    # 1.1 If exists then nothing needs to be done
    # 1.2 Otherwise, copy original yaml as another file with bkup in the name
    [ $(sudo ls /etc/elasticsearch/elasticsearch_bkup.yml) ] \
    && echo "Already Exists:/etc/elasticsearch/elasticsearch_bkup.yml" \
    || \
       ( sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch_bkup.yml \
         && echo "Created: /etc/elasticsearch/elasticsearch_bkup.yml" \
       )
}
function set_http_host(){
    # 1. First take a backup of ES's config file
    # 2. Remove line containing http.host from it.
    # 3. Append "http.host: 0.0.0.0" at the end of the config file
    backup_es_yml \
    && sudo sed -i '/http.host/d' /etc/elasticsearch/elasticsearch.yml \
    && echo "http.host: 0.0.0.0" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
}
function check_curl(){
    # Check if ES service is running.
    # Curl with timeout of 5 seconds.
    curl --max-time 5 http://localhost:9200
    CURL_RESULT=$?
    if [ $CURL_RESULT = "0" ]
    then
        echo "Curl succeeded. Elasticsearch is running."
    else
        echo "Curl failed with: $CURL_RESULT"
        return 255
    fi
}
function restart_elasticsearch(){
    sudo systemctl restart elasticsearch \
    && sudo systemctl is-active elasticsearch
}
# Start Install
set -x \
&& install_elasticsearch \
&& set_http_host \
&& restart_elasticsearch \
&& check_curl \
&& echo "All Done. Elasticsearch Installation completed successfully" \
&& set +x
