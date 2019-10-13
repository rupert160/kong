#!/usr/bin/env bash

PROJECT_DIR="$(cd "`dirname $0`"/..; pwd)"
DOWNLOADS_DIR="${PROJECT_DIR}/downloads"
BINARY_DIR="${PROJECT_DIR}/bin"
TFSPEC_DIR="${PROJECT_DIR}/infrastructure/deployment-pipeline/"

TERRAFORM_VERSION='0.12.10'
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"
TERRAFORM_BIN='terraform'
TERRAFORM="${BINARY_DIR}/${TERRAFORM_BIN}"

function exit_error(){
   echo "$1"
   exit 1
}

function export_aws_credentials(){
  echo "Warning - using your default AWS credentials..."

  if ! [[ -r "${HOME}/.aws/credentials" ]]; then
     exit_error "error: ${HOME}/.aws/credentials needs to be readable" 
  fi
  
  if ! [[ -r "${HOME}/.aws/config" ]]; then
     exit_error "error: ${HOME}/.aws/config needs to be readable" 
  fi
  
  $(sed -n '/\[default\]/,/\[/s/^\s*//p' ~/.aws/{config,credentials} | \
  	grep --color=never 'access_key\|region' | \
  	sed 's/region/aws_default_region/' | \
  	sed -e 's/\(.*\)=\(.*\)/export \U\1=\E\2/'
  )
}

function install_terraform(){
   mkdir -p "$PROJECT_DIR" "${DOWNLOADS_DIR}" "${BINARY_DIR}"
   cd "$PROJECT_DIR"
   
   if ! [[ -f "${DOWNLOADS_DIR}/${TERRAFORM_ZIP}" ]]; then
      wget --directory-prefix="${DOWNLOADS_DIR}" "${TERRAFORM_URL}"
   fi
   
   rm "$BINARY_DIR/$TERRAFORM_BIN"
   unzip -d "$BINARY_DIR" "${DOWNLOADS_DIR}/${TERRAFORM_ZIP}"
   
   chmod u+x "${TERRAFORM}"
   
   if ! [[ -x "${TERRAFORM}" ]]; then
      exit_error "error: terreform binary is not executable" 
   fi

   ${TERRAFORM} version
}

function setup_codecommit(){
   echo "follow ssh instructions here before proceeding..."
   echo "https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html#setting-up-ssh-unixes-keys"
   
   echo "have you setup ~/.ssh/config with a \"Host git-codecommit.*.amazonaws.com\" entry?"
   select yn in "Yes" "No"; do
       case $yn in
           Yes ) git remote add codecommit ssh://git-codecommit.ap-southeast-2.amazonaws.com/v1/repos/docker-image-build; break;;
           No ) exit;;
       esac
   done
}

function change_aws_account(){
   echo "have you amended your account the project_root/buildspec.yml from 735655096069 file?"
   select yn in "Yes" "No"; do
       case $yn in
           Yes ) break;;
           No ) exit;;
       esac
   done
}


function kong_config(){
   export_aws_credentials
   install_terraform
   setup_codecommit
   change_aws_account
}

function kong_build(){
   export_aws_credentials
   cd ${TFSPEC_DIR}
   #t 0.12upgrade
   "${TERRAFORM}" init .
   "${TERRAFORM}" plan -out=create-pipeline
   "${TERRAFORM}" apply create-pipeline
   git push --set-upstream codecommit master
   aws codepipeline start-pipeline-execution --name docker-image-build
}

function tear_down(){
   "${TERRAFORM}" plan -destroy -out=destroy-pipeline
   "${TERRAFORM}" apply destroy-pipeline
}

#function kong_deploy(){
#   
#}

#kong_config
#kong_build
tear_down
