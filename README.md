# Описание:

Зашифруй свой трафик с помощью:
  TOR + DNS-over-HTTPS(https://github.com/AdguardTeam/dnsproxy)
# Работает на:

Linux(Ubuntu 20.04.3 LTS)
# Использование:

- устанавливаем GIT:

  **sudo apt install git -y**

- копируем репозиторий:

  git clone https://github.com/hulumulu801/no_watching_RKN.git

- переходим в папку:

  cd no_watching_RKN/
  
- делаем файлы исполняемыми:

  chmod +x instal_and_start.sh start_DNS_over_HTTPS.sh deactivate.sh
  
- запуск:

  sudo ./instal_and_start.sh
  
- после перезагрузки ПК активен только TOR, для того чтобы перенаправить DNS запросы, необходимо:

  - снова переходим в папку:

    cd no_watching_RKN/
