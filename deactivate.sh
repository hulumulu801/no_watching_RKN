#!/bin/bash

COMMAND_CLEAR_TERM=`clear && clear`

function deleting_file_or_lines_from_file_environment()
{
  PATH_ENVIRONMENT_CONFIG=/etc/environment
  PATH_ENVIRONMENT_CONFIG_OLD=/etc/environment--old

  COMMAND_DELETE_FILE_ENVIRONMENT_CONFIG="sudo rm $PATH_ENVIRONMENT_CONFIG"
  COMMAND_RENAME_FILE_ENVIRONMENT_CONFIG="sudo mv $PATH_ENVIRONMENT_CONFIG_OLD $PATH_ENVIRONMENT_CONFIG"

  if test -e $PATH_ENVIRONMENT_CONFIG_OLD; then
    $COMMAND_DELETE_FILE_ENVIRONMENT_CONFIG
    $COMMAND_RENAME_FILE_ENVIRONMENT_CONFIG
  fi
}

function remov_packages()
{
  COMMAND_REMOVE_PACKAGES_TOR="sudo apt-get remove tor -y"
  COMMAND_REMOVE_PACKAGES_TOR_1="sudo apt-get purge tor -y"
  COMMAND_REMOVE_PACKAGES_PRIVOXY="sudo apt-get remove privoxy -y"
  COMMAND_REMOVE_PACKAGES_PRIVOXY_1="sudo apt-get purge privoxy -y"

  echo $COMMAND_CLEAR_TERM
  echo
  echo "UNINSTAL TOR..."
  echo
  sleep 2
  $COMMAND_REMOVE_PACKAGES_TOR
  $COMMAND_REMOVE_PACKAGES_TOR_1

  echo $COMMAND_CLEAR_TERM
  echo
  echo "UNINSTAL PRIVOXY..."
  echo
  sleep 2
  $COMMAND_REMOVE_PACKAGES_PRIVOXY
  $COMMAND_REMOVE_PACKAGES_PRIVOXY_1
}

function remov_folder_download()
{
  PATH_FOLDER_DOWNLOAD=./download/

  COMMAND_DELETED_FOLDER_DOWNLOAD="sudo rm -rf $PATH_FOLDER_DOWNLOAD"

  if test -e $PATH_FOLDER_DOWNLOAD; then
    $COMMAND_DELETED_FOLDER_DOWNLOAD
  fi
}

function remov_go()
{
  PATH_OPT_GOLANG=/opt/go

  COMMAND_DELETED_GO="sudo rm -rf $PATH_OPT_GOLANG"

  if test -e $PATH_OPT_GOLANG; then
    $COMMAND_DELETED_GO
  fi
}

function reboot_now()
{
  echo $COMMAND_CLEAR_TERM
  echo
  echo "Для вступления изменений в силу нужна перезагрузка!"
  echo "Перезагрузить?"
  echo "Y/N"
  read reboot_name
  if [ "${reboot_name^^}" == "Y" ]; then
    reboot
  else
    echo "Перезагрузите ПК самостоятельно!"
  fi
}

if [ "$EUID" -eq 0 ]; then

  deleting_file_or_lines_from_file_environment

  remov_packages

  remov_folder_download

  remov_go

  reboot_now

else
  echo $COMMAND_CLEAR_TERM
  echo
  echo "Запустите скрипт от имени суперпользователя! Например:"
  echo "sudo ./deactivate.sh"
  echo
  exit $E_XCD
fi
