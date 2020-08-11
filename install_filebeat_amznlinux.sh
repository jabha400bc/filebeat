#!/bin/bash
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function install_filebeat(){
    curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.8.1-x86_64.rpm \
    && sudo rpm -vi filebeat-7.8.1-x86_64.rpm
}
# Function to take a backup of filebeat's config yaml because we will be overwriting it.
function backup_filebeat_yml(){
    # 1. First check if elasticsearch_bkup.yml already exists.
    # 1.1 If exists then nothing needs to be done
    # 1.2 Otherwise, copy original yaml as another file with bkup in the name
    [ $(sudo ls /etc/filebeat/filebeat_bkup.yml) ] \
    && echo "Already Exists:/etc/filebeat/filebeat_bkup.yml" \
    || \
       ( sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat_bkup.yml \
         && echo "Created: /etc/filebeat/filebeat_bkup.yml" \
       )
}
# Function to check filebeat's config yaml file whether it is correct or not.
function check_filebeat_config(){
    sudo filebeat test config -c /etc/filebeat/filebeat.yml
}
# Function to overwrite filebeat's config yaml file with ours.
function copy_filebeat_yml(){
    # 1. Take backup of filebeat's original yaml file.
    # 2. Overwrite filebeat's config yaml file with ours
    # 3. Validate the filebeat config is correct
    backup_filebeat_yml \
	&& cat ${SCRIPT_DIR}/filebeat.yml | sudo tee /etc/filebeat/filebeat.yml \
    && check_filebeat_config
}
# Function to restart filebeat service, specially after changing its config yaml.
function restart_filebeat(){
    # 1. Restart filebeat service.
    # 2. CHeck if service status is active.
    sudo systemctl restart filebeat \
    && sudo systemctl is-active --quiet filebeat
}
# Function to configure filebeat.
function configure_filebeat(){
    # 1. Overwrite filebeat's config yaml file with ours
    # 2. Restart filebeat service, specially after changing its config yaml
    copy_filebeat_yml \
    && restart_filebeat
}
# Start Install
# 1. Install filebeat.
# 2. Configure filebat's yaml config etc
# 3. Print success message if all went well.
set -x \
&& install_filebeat \
&& configure_filebeat \
&& echo "All Done: Filebeat Installation completed successfully" \
&& set +x