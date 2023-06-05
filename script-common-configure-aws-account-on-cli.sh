#!bin/bash
# RSP-23
# This script is for configuring aws account on cli 
# user can assume the role based on role arn and external id
# user needs to pass three arguments as input while running this script 
# 1) mfa arn
# 2) role arn of the account which you want to assume
# 3) external-id  
# This script will setup two aws profiles
# 1) mfa-profile
# 2) assumed-role-profile
# user needs to pass --profile {profile name} tag with aws commands to select specific credentials 
# command to run this script
# > sh script-common-configure-aws-account-on-cli.sh {mfa arn} {role arn} {external id}

aws configure

#---------------------------MFA-steps-start------------------------------------
# user input
read -p 'Enter MFA code = ' mfa
role=$(aws sts get-session-token --duration-seconds 43200 --serial-number $1 --token-code $mfa)

# aws configure
aws configure set aws_access_key_id $(echo $role | awk '{print $5}' | tr -d '"' | tr -d ',') --profile mfa-profile
aws configure set aws_secret_access_key $(echo $role | awk '{print $7}' | tr -d '"' | tr -d ',') --profile mfa-profile
aws configure set aws_session_token $(echo $role | awk '{print $9}' | tr -d '"' | tr -d ',') --profile mfa-profile

#---------------------------MFA-steps-end------------------------------------

#---------------------------Asume-role-steps-starts------------------------------------

value=$(aws sts assume-role --role-arn $2 --role-session-name cli-Session  --external-id $3 --profile mfa-profile)
aws configure set aws_access_key_id $(echo $value | awk '{print $5}' | tr -d '"' | tr -d ',') --profile assumed-role-profile
aws configure set aws_secret_access_key $(echo $value | awk '{print $7}' | tr -d '"' | tr -d ',') --profile assumed-role-profile
aws configure set aws_session_token $(echo $value | awk '{print $9}' | tr -d '"' | tr -d ',') --profile assumed-role-profile
#---------------------------Asume-role-steps-ends------------------------------------
