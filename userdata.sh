#!/bin/bash

set-hostname -skip-apply ${component}
ansible-pull -i localhost, -U https://github.com/janardhanReddy-B/roboshop-ansible-b roboshop.yml -e role_name=${component} -e env=${env} &>>/opt/ansible.log