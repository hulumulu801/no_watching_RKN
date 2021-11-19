#!/bin/bash

COMMAND_CLEAR_TERM=`clear && clear`

PATH_PRIVOXY_CONFIG=/etc/privoxy/config
PATH_ENVIRONMENT_CONFIG=/etc/environment
PATH_TO_THE_SCRIPT_start_DNS_over_HTTPS=./start_DNS_over_HTTPS.sh

function update_and_install_git_tor_privoxy()
{
  STATUS_CHECK="Status: install ok installed"

  COMMAND_UPDATE="sudo apt-get update"
  COMMAND_INSTALL_GIT="sudo apt install git -y"
  COMMAND_INSTALL_TOR="sudo apt-get install tor -y"
  COMMAND_CHEK_INSTALL_TOR=`dpkg -s tor | grep "Status"`
  COMMAND_INSTALL_PRIVOXY="sudo apt-get install privoxy -y"
  COMMAND_CHEK_INSTALL_PRIVOXY=`dpkg -s privoxy | grep "Status"`

  echo $COMMAND_CLEAR_TERM
  echo
  echo "UPDATE SYSTEM..."
  echo
  sleep 2
  $COMMAND_UPDATE

  echo $COMMAND_CLEAR_TERM
  echo
  echo "INSTALL GIT..."
  echo
  sleep 2
  $COMMAND_INSTALL_GIT

  if [ "$COMMAND_CHEK_INSTALL_TOR" != "$STATUS_CHECK" ]; then
    echo $COMMAND_CLEAR_TERM
    echo
    echo "INSTALL TOR..."
    echo
    sleep 2
    $COMMAND_INSTALL_TOR
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Tor ==> установлен!"
    echo
    sleep 2
  fi
  if [ "$COMMAND_CHEK_INSTALL_PRIVOXY" != "$STATUS_CHECK" ]; then
    echo $COMMAND_CLEAR_TERM
    echo
    echo "INSTALL PRIVOXY..."
    echo
    sleep 2
    $COMMAND_INSTALL_PRIVOXY
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Privoxy ==> установлен!"
    echo
    sleep 2
  fi
}

function check_and_install_python3_and_pip()
{
  CHECK_PYTHON_3=`python3 -V`
  PYTHON_RE="Python 3[.0-9]+$"

  CHECK_PYTHON_3_PIP=`python3 -m pip --version`
  PIP_RE="pip [./()0-9a-zA-Z]"

  COMMAND_INSTALL_PIP="sudo apt install python3-pip -y"
  COMMAND_UPGRADE_PIP="python3 -m pip install --upgrade pip"

  if [[ $CHECK_PYTHON_3 =~ $PYTHON_RE ]]; then
    if [[ $CHECK_PYTHON_3_PIP =~ $PIP_RE ]]; then
      echo $COMMAND_CLEAR_TERM
      echo
      echo "Python3 and pip3 ==> установлены!"
      echo
      sleep 2
    else
      echo $COMMAND_CLEAR_TERM
      echo
      echo "INSTALL PIP"
      echo
      sleep 2
      $COMMAND_INSTALL_PIP
      echo $COMMAND_CLEAR_TERM
      echo
      echo "UPGRADE PIP"
      echo
      sleep 2
      $COMMAND_UPGRADE_PIP
    fi
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Установите Python 3 самостоятельно!"
    echo "И запустите скрипт еще раз!"
    echo "Выход!"
    exit $E_XCD
  fi
}

function install_requirements_and_start_python_script()
{
  PATH_PYTHON_REQUIREMENTS=./requirements.txt
  PATH_PYTHON_SCRIPT=./python_script/cheking_and_download_go_and_dnsproxy.py

  COMMAND_INSTALL_REQUIREMENTS="pip3 install -r ${PATH_PYTHON_REQUIREMENTS}"
  COMMAND_START_PYTHON_SCRIPT="python3 $PATH_PYTHON_SCRIPT"

  if test -e $PATH_PYTHON_REQUIREMENTS && test -e $PATH_PYTHON_SCRIPT; then
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Производится проверка установленных pip пакетов!"
    echo
    sleep 2
    for str_pip_req in `cat $PATH_PYTHON_REQUIREMENTS`; do
      if pip3 freeze | grep -x $str_pip_req; then
        echo $COMMAND_CLEAR_TERM
        echo
        echo "Пакет: $str_pip_req ==> установлен!"
        echo
        sleep 1
      else
        echo $COMMAND_CLEAR_TERM
        echo
        echo "Производится установка пакетов pip!"
        echo
        $COMMAND_INSTALL_REQUIREMENTS
      fi
    done

    echo $COMMAND_CLEAR_TERM
    echo
    echo "Запуск скрипта: $PATH_PYTHON_SCRIPT"
    echo
    $COMMAND_START_PYTHON_SCRIPT

  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Файлы: $PATH_PYTHON_REQUIREMENTS $PATH_PYTHON_SCRIPT отсутсвут/перемещены!"
    echo "Выход!"
    exit $E_XCD
  fi
}

function write_data_privoxy_config()
{
  GREP_FIND_5=$(cat $PATH_PRIVOXY_CONFIG | grep "forward-socks5 / localhost:9050 .")
  GREP_FIND_4=$(cat $PATH_PRIVOXY_CONFIG | grep "forward-socks4 / localhost:9050 .")
  GREP_FIND_4a=$(cat $PATH_PRIVOXY_CONFIG | grep "forward-socks4a / localhost:9050 .")

  if test -e $PATH_PRIVOXY_CONFIG; then
    if [ "$GREP_FIND_5" = "forward-socks5 / localhost:9050 ." ]; then
      :
    else
      echo "###########################################" | tee -a $PATH_PRIVOXY_CONFIG > /dev/null
      echo "forward-socks5 / localhost:9050 ." | tee -a $PATH_PRIVOXY_CONFIG > /dev/null
    fi
    if [ "$GREP_FIND_4" = "forward-socks4 / localhost:9050 ." ]; then
      :
    else
      echo "forward-socks4 / localhost:9050 ." | tee -a $PATH_PRIVOXY_CONFIG > /dev/null
    fi
    if [ "$GREP_FIND_4a" = "forward-socks4a / localhost:9050 ." ]; then
      :
    else
      echo "forward-socks4a / localhost:9050 ." | tee -a $PATH_PRIVOXY_CONFIG > /dev/null
    fi
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Не найден файл $PATH_PRIVOXY_CONFIG"
    exit $E_XCD
  fi
}

function write_data_environment()
{
  COMMAND_DELETED_FOLDER_DOWNLOAD="sudo rm -rf ./download/"
  COMMAND_COPY_ENVIRONMENT="sudo cp $PATH_ENVIRONMENT_CONFIG $PATH_ENVIRONMENT_CONFIG--old"

  FTP_PROXY=$(cat $PATH_ENVIRONMENT_CONFIG | grep 'export ftp_proxy="http://localhost:8118/"')
  HTTP_PROXY=$(cat $PATH_ENVIRONMENT_CONFIG | grep 'export http_proxy="http://localhost:8118/"')
  HTTPS_PROXY=$(cat $PATH_ENVIRONMENT_CONFIG | grep 'export https_proxy="http://localhost:8118/"')
  ALL_PROXY=$(cat $PATH_ENVIRONMENT_CONFIG | grep 'export all_proxy="socks://localhost:9050/"')
  NO_PROXY=$(cat $PATH_ENVIRONMENT_CONFIG | grep 'export no_proxy="localhost,127.0.0.0/8,::1"')

  echo $COMMAND_CLEAR_TERM
  echo
  echo "Перенаправить весь трафик через TOR?"
  echo "Y/N"
  echo "P.S.: После соглашения будет произведен перезапуск системы!"
  read next_y_n
  if [ "${next_y_n^^}" == "Y" ]; then
    if test -e $PATH_ENVIRONMENT_CONFIG; then
      $COMMAND_COPY_ENVIRONMENT
      if [ "$FTP_PROXY" = 'export ftp_proxy="http://localhost:8118/"' ]; then
        :
      else
        echo "###########################################" | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
        echo 'export ftp_proxy="http://localhost:8118/"' | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
      fi

      if [ "$HTTP_PROXY" = 'export http_proxy="http://localhost:8118/"' ]; then
        :
      else
        echo 'export http_proxy="http://localhost:8118/"' | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
      fi

      if [ "$HTTPS_PROXY" = 'export https_proxy="http://localhost:8118/"' ]; then
        :
      else
        echo 'export https_proxy="http://localhost:8118/"' | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
      fi

      if [ "$ALL_PROXY" = 'export all_proxy="socks://localhost:9050/"' ]; then
        :
      else
        echo 'export all_proxy="socks://localhost:9050/"' | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
      fi

      if [ "$NO_PROXY" = 'export no_proxy="localhost,127.0.0.0/8,::1"' ]; then
        :
      else
        echo 'export no_proxy="localhost,127.0.0.0/8,::1"' | tee -a $PATH_ENVIRONMENT_CONFIG > /dev/null
      fi
    else
      echo $COMMAND_CLEAR_TERM
      echo
      echo "Не найден файл $PATH_ENVIRONMENT_CONFIG"
      $COMMAND_DELETED_FOLDER_DOWNLOAD
      exit $E_XCD
    fi
  else
    echo $COMMAND_CLEAR_TERM
    $COMMAND_DELETED_FOLDER_DOWNLOAD
    echo
    echo "Выход!"
    echo
    exit $E_XCD
  fi
}

function install_golang()
{
  PATH_OPT=/opt/
  PATH_OPT_GOLANG=/opt/go
  PATH_DOWNLOAD_GOLANG_FOLDER=./download/go_downoad/
  PATH_DOWNLOAD_GOLANG=./download/go_downoad/*.*

  COMMAND_CHEK_INSTAL_GO=`cat /etc/environment | grep "/opt/go/bin"`
  COMMAND_CHEK_FILE_GOLANG=`ls $PATH_DOWNLOAD_GOLANG_FOLDER | wc -l`

  COMMAND_CREAT_FOLDER_OPT="sudo mkdir $PATH_OPT"
  COMMAND_UNPACKING_GOLANG="sudo tar -C $PATH_OPT -xzf $PATH_DOWNLOAD_GOLANG"

  if test -e $PATH_OPT; then
    :
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Создаю папку: $PATH_OPT"
    sleep 1
    $COMMAND_CREAT_FOLDER_OPT
  fi
  if test -e $PATH_DOWNLOAD_GOLANG_FOLDER; then
    if [ $COMMAND_CHEK_FILE_GOLANG -gt 0 ]; then
      if [ "$COMMAND_CHEK_INSTAL_GO" ] || test -e $PATH_OPT_GOLANG; then
        echo $COMMAND_CLEAR_TERM
        echo
        echo "В системе установлен GOLANG! Рекомендуется удалить его и запустите скрипт еще раз!"
        sleep 3
      else
        echo $COMMAND_CLEAR_TERM
        echo
        echo "Распаковка GOLANG!"
        echo
        sleep 1
        $COMMAND_UNPACKING_GOLANG
        if test -e $PATH_OPT_GOLANG; then
          RE_PATH_ENV_ENVIRONMENT=$(sudo sed -i '/^PATH=".*"$/s/"$/:\/opt\/go\/bin"/g' $PATH_ENVIRONMENT_CONFIG)
          echo $COMMAND_CLEAR_TERM
          echo
          echo "Добавление пути к исполняемым файлам GOLANG!"
          sleep 1
          echo
          echo $RE_PATH_ENV_ENVIRONMENT
        else
          echo $COMMAND_CLEAR_TERM
          echo
          echo "Папка: $PATH_OPT_GOLANG не найдена!"
          echo "Выход!"
          echo
          exit $E_XCD
        fi
      fi
    else
      echo $COMMAND_CLEAR_TERM
      echo
      echo "В папке: $PATH_DOWNLOAD_GOLANG_FOLDER нет файлов!"
      echo "Выход!"
      exit $E_XCD
    fi
  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Папка: $PATH_DOWNLOAD_GOLANG_FOLDER не существует/не скачана!"
    echo "Выход!"
    exit $E_XCD
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
  if test -e $PATH_TO_THE_SCRIPT_start_DNS_over_HTTPS; then

    update_and_install_git_tor_privoxy

    check_and_install_python3_and_pip

    install_requirements_and_start_python_script

    write_data_privoxy_config

    write_data_environment

    install_golang

    reboot_now

  else
    echo $COMMAND_CLEAR_TERM
    echo
    echo "Отсутствует скрипт: $PATH_TO_THE_SCRIPT_start_DNS_over_HTTPS"
    echo "Выход!"
    echo
    exit $E_XCD
  fi
else
  echo $COMMAND_CLEAR_TERM
  echo
  echo "Запустите скрипт от имени суперпользователя! Например:"
  echo "sudo ./instal_and_start_TOR.sh"
  echo
  exit $E_XCD
fi
