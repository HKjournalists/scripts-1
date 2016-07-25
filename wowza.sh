#!/bin/bash
ssh-add -D
num=$1
ssh -o StrictHostKeyChecking=no -i Downloads/Wowza_production.pem ec2-user@origin-wowzain${num}.livfame.com
