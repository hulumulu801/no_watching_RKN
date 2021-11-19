#!/bin/bash

COMMAND_CLEAR_TERM=`clear && clear`
PATH_DOWNLOAD_DNSPROXY=$(realpath ./download/dnsproxy_download)

function build_dnsproxy()
{
  COMMAND_CHEK_FILE_DNSPROXY=$(ls $PATH_DOWNLOAD_DNSPROXY/ | wc -l)
  COMMAND_CHMOD=$(sudo chmod 777 -R $PATH_DOWNLOAD_DNSPROXY/)
  COMMAND_BUILD="go build -mod=vendor"

  if test -e $PATH_DOWNLOAD_DNSPROXY; then
    if [ $COMMAND_CHEK_FILE_DNSPROXY -gt 10 ]; then
      $COMMAND_CHMOD
      echo $COMMAND_CLEAR_TERM
      echo
      echo "Компиляция..."
      echo
      cd $PATH_DOWNLOAD_DNSPROXY
      $COMMAND_BUILD
      sleep 5
    else
      echo $COMMAND_CLEAR_TERM
      echo
      echo "В папке: $PATH_DOWNLOAD_DNSPROXY нет файлов!"
      echo "Выход!"
      exit $E_XCD
    fi
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Папка: $PATH_DOWNLOAD_DNSPROXY не существует/не скачана!"
    echo "Выход!"
    exit $E_XCD
  fi
}

function closing_port_53()
{
  STATUS_CHECK_53_PORT="Active: active"

  COMMAND_CHEKING_53_PORT=`sudo systemctl status systemd-resolved.service | grep -o "Active: active"`
  COMMAND_STOP_SYSTEMD_RESOLVED_SERVICE="sudo systemctl stop systemd-resolved.service"

  if [ echo $COMMAND_CHEKING_53_PORT != "$STATUS_CHECK_53_PORT" ]; then
    :
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Stop systemd-resolved.service"
    echo
    sleep 2
    $COMMAND_STOP_SYSTEMD_RESOLVED_SERVICE
  fi
}

function start_DNS_over_HTTPS()
{
  COMMAND_START_DNS_over_HTTPS="sudo $PATH_DOWNLOAD_DNSPROXY/dnsproxy -u https://dns.adguard.com/dns-query -b 1.1.1.1:53"

  echo $COMMAND_CLEAR_TERM
  echo
  echo "Start DNS-over-HTTPS"
  echo
  $COMMAND_START_DNS_over_HTTPS
}

build_dnsproxy

closing_port_53

start_DNS_over_HTTPS
