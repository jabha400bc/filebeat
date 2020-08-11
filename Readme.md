# Filebeat tutorial
1. This document describes how to install and test filebeat & elasticsearch.
    * We will install filebeat and elasticsearch.
    * Simulate two apps app1 and app2 writing logs
    * The two log entries will automatically get forwarded to elasticsearch.
    * Then we will query elasticsearch to verify that logs are present.

## Steps
1. This section contains steps for this tutorial.

### Prepare
1. Use ubuntu 18.04 instance. Or Amazon Linux instance. 
    * Make sure to use correct scripts for your platform.
2. Clone this repo.
3. Go to repo's directory.

### Install Elasticsearch
1. Run elasticsearch installer.  Make sure to use correct scripts for your platform.
    ```
    ./install_elasticsearch.sh
    ```
2. It should print message that installation was successful.
3. Feel free to look at the script's code.

### Install filebeat.
1. Run filebeat installer.  Make sure to use correct scripts for your platform.
    ```
    ./install_filebeat.sh
    ```
2. It should print message that installation was successful.
3. Feel free to look at the script's code.

#### Understand filebeat.yml configuration.
1. Review filebeat.yml in this repo's filebeat folder.
2. It configures two inputs
3. **Input 1:** app1
    * Monitors /var/log/app1_beat*.log
    * Assigns a custom field "app_name" a value of "app1".
        - The app_name will be used in elasticsearch to create a separate index for this app's log.
4. **Input 2:** app2
    * Monitors /var/log/app2_beat*.log
    * Assigns a custom field "app_name" a value of "app2".
        - The app_name will be used in elasticsearch to create a separate index for this app's log.
5. **Elasticsearch Output**: Look at "output.elasticsearch:" section.
    * The logs will be sent to local elasticsearch running on port 9200.
    * The index name will be created based on
        - app_name (that we assigned in the input section)
        - agent version of the filebeat agent.
        - Current date.
    * So, the index names in elasticsearch will look like following.
        - log-app1-7.8.1-2020.08.08
        - log-app2-7.8.1-2020.08.08
6. When using custom index names, we need some more config as seen by following lines. The "log" prefix is what we are using for our index names. Refer [index section in of elastic documentation](https://www.elastic.co/guide/en/beats/filebeat/current/elasticsearch-output.html#index-option-es).
    ```
    setup.template.name: "log"
    setup.template.pattern: "log-*"
    setup.ilm.enabled: false
    ```

### Test the filebeat configuration
1. Now that you have
    * Installed and configured elasticsearch
    * Installed and configured filebeat.
    * Understood the filebeat config yaml.
2. It is time to test our configuration.
3. Write some log entries in thw two log files we configured.
    ```
    echo test1 | sudo tee -a /var/log/app1_beat1.log
    echo test1 | sudo tee -a /var/log/app2_beat1.log
    echo test2 | sudo tee -a /var/log/app1_beat1.log
    echo test2 | sudo tee -a /var/log/app2_beat1.log
    ```
4. After that wait for 5 to 10 seconds.
5. Query elasticsearch's list of indexes.
    ```
    curl localhost:9200/_cat/indices
    ```
6. You should see two indexes similar to following (apart from other indexes). Your index names will be different because these are derived based on date.
    ```
    yellow open log-app1-7.8.1-2020.08.08        cRGxrIEbTbu00D9jShTzTg 1 1     1 0   8.5kb   8.5kb
    yellow open log-app2-7.8.1-2020.08.08        zDWb7kyqQ4G9qj-dHlIJZg 1 1     0 0    208b    208b
    ```
7. Now, query the indexes. Make sure to use correct index names. Your index names will be different because these are derived based on date.
    ```
    curl localhost:9200/log-app1-7.8.1-2020.08.08/_search
    curl localhost:9200/log-app2-7.8.1-2020.08.08/_search
    ```
8. You should see the mesages that you logged in those log files.
9. Congratulations!! You successfully completed the tutorial.

### Cleanup
1. Let us cleanup all the installations and files etc.
    ```
    ./cleanup.sh
    ```
