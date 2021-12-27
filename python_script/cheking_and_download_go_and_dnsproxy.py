#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import requests
import platform
from git import Repo
from time import sleep
from bs4 import BeautifulSoup as bs
from fake_useragent import UserAgent

def get_system_information():
    platform_machine = platform.machine()
    platform_machine = re.sub("_", "-", platform_machine)
    platform_system = platform.system()

    dict_plt = {
                "machine": platform_machine,
                "system": platform_system
    }

    return dict_plt

def get_retry_requests_html(*arg):
    urls = arg[0]
    links_url = []
    for url in urls:
        headers = {
                    "User-Agent": UserAgent().random
        }
        r = requests.get(url, headers = headers)
        if r.status_code == 200:
            dict_url = {
                        "url": url,
                        "requests": r.text
                        }
            links_url.append(dict_url)
        else:
            print(f"Ошибка! Сервер: {url} ===> Код ответа: {r.status_code}\nЖду 9 секунд и повторю запрос!")
            sleep(9)
            r = requests.get(url, headers = headers)
            if r.status_code == 200:
                dict_url = {
                            "url": url,
                            "requests": r.text
                            }
                links_url.append(dict_url)
            else:
                print(f"Ошибка! Сервер: {url} ===> Код ответа: {r.status_code}\nЖду 5 секунд и повторю запрос!")
                sleep(5)
                r = requests.get(url, headers = headers)
                if r.status_code == 200:
                    dict_url = {
                                "url": url,
                                "requests": r.text
                                }
                    links_url.append(dict_url)
                else:
                    if re.search("golang", url):
                        print(
                                f"""Ошибка!
                                \nОтвет сервера: {r.status_code}!!!
                                \nНе удалось получить ответ от сайта: {url}!!!
                                \nСкачайте последнюю версию языка golang самостоятельно!!!
                                """
                        )
                    elif re.search("github", url):
                        print(
                                f"""Ошибка!
                                \nОтвет сервера: {r.status_code}!!!
                                \nНе удалось получить ответ от сайта: {url}!!!
                                \nСкачайте dnsproxy самостоятельно!!!
                                """
                        )
    return links_url

def get_retry_requests_github(lists_urls):
    for dict_url in lists_urls:
        if dict_url["url"] == "https://github.com/AdguardTeam/dnsproxy":
            url = dict_url["url"]
            soup = bs(dict_url["requests"], "lxml")
            div_version = soup.find(
                            "div", id = "repo-content-pjax-container"
            ).find(
                            "article", class_ = "markdown-body entry-content container-lg"
            ).find(
                            string = re.compile("You will need go")
            )
            version_go_github = str(div_version).split("v")[-1].split("or")[0]
            dict_github = {
                            "version_go": version_go_github,
                            "url_download_dnsproxy": f"{url}.git"
            }
            return dict_github

def get_retry_requests_golang(lists_urls):
    lists_all = []
    for dict_url in lists_urls:
        if dict_url["url"] == "https://golang.org/dl/":
            soup = bs(dict_url["requests"], "lxml")
            divs = soup.find(
                                        "body", class_ = "Site"
            ).find(
                                        "main", class_ = re.compile("SiteContent ")
            ).find(
                                        "article", class_ = "Downloads Article"
            ).find(
                                        "div", class_ = "toggleVisible"
            ).find(
                            "table", class_ = "downloadtable"
            ).find_all("tr")
            for div in divs:
                name_OS_Linux = div.find(
                                            string = re.compile("Lin")
                )
                name_OS_Windows = div.find(
                                            string = re.compile("Win")
                )
                name_OS_Mac = div.find(
                                            string = re.compile("mac")
                )

                arh_proc_x86_x86_64 = div.find(
                                            string = re.compile("x86")
                )
                arh_proc_ARM64 = div.find(
                                            string = re.compile("ARM64")
                )

                link_download = div.find(
                                        "a", class_ = "download"
                )

                if name_OS_Linux:
                    if arh_proc_x86_x86_64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_linux_x86_x64 = {
                                                        f"Linux---{arh_proc_x86_x86_64}": link_download
                            }
                            lists_all.append(dict_os_linux_x86_x64)
                    elif arh_proc_ARM64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_linux_arm64 = {
                                                        f"Linux---{arh_proc_ARM64}": link_download
                            }
                            lists_all.append(dict_os_linux_arm64)
                elif name_OS_Windows:
                    if arh_proc_x86_x86_64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_windows_x86_x64 = {
                                                        f"Windows---{arh_proc_x86_x86_64}": link_download
                            }
                            lists_all.append(dict_os_windows_x86_x64)
                    elif arh_proc_ARM64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_windows_arm64 = {
                                                        f"Windows---{arh_proc_ARM64}": link_download
                            }
                            lists_all.append(dict_os_windows_arm64)
                elif name_OS_Mac:
                    if arh_proc_x86_x86_64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_mac_x86_x64 = {
                                                        f"Mac---{arh_proc_x86_x86_64}": link_download
                            }
                            lists_all.append(dict_os_mac_x86_x64)
                    elif arh_proc_ARM64:
                        if link_download:
                            link_download = link_download.get("href")
                            link_download = f"https://golang.org{link_download}"
                            dict_os_mac_arm64 = {
                                                        f"Mac---{arh_proc_ARM64}": link_download
                            }
                            lists_all.append(dict_os_mac_arm64)

    return lists_all

def get_link_golang_and_github(dict_system_information, dict_github, lists_golang):
    arh_machine = dict_system_information["machine"]
    system_machine = dict_system_information["system"]
    arh_and_system_machine = f"{system_machine}---{arh_machine}"

    version_go_github = dict_github["version_go"]
    link_dnspoxy_github = dict_github["url_download_dnsproxy"]

    for list_golang in lists_golang:
        try:
            link_golang = list_golang[arh_and_system_machine]
            if link_golang:
                version_go_golang = link_golang.split("/go")[-1].split(f".{system_machine.lower()}")[0]
                version_go_golang = re.sub(r"\.[^.]*$", "", version_go_golang)
                dict_download = {
                                    "go": link_golang,
                                    "github": link_dnspoxy_github
                }
                return dict_download
        except KeyError as e:
            pass

def download(dict_download):
    go_download_url = dict_download["go"]
    name_file_go = str(go_download_url).split("/")[-1]

    github_download_url = dict_download["github"]

    folder = "./download"
    path_folder = os.path.abspath(folder)
    path_folder_go = f"{path_folder}/go_downoad"
    path_folder_github = f"{path_folder}/dnsproxy_download"

    if not os.path.exists(path_folder_go) and not os.path.exists(path_folder_github):
        os.makedirs(path_folder_go)
        os.makedirs(path_folder_github)

    Repo.clone_from(github_download_url, path_folder_github)
    if os.path.exists(path_folder_github):
        print(f"Dnsproxy по ссылке: {github_download_url} ==> скачен!")

    abs_path_path_folder_go = f"{path_folder_go}/{name_file_go}"

    response_go = requests.get(go_download_url, stream = True)

    if response_go.status_code == 200:
        with open(abs_path_path_folder_go, "wb") as f:
            f.write(response_go.raw.read())
    if os.path.exists(abs_path_path_folder_go):
        print(f"Golang по ссылке: {go_download_url} ==> скачен!")

def main():
    url_golang = "https://golang.org/dl/"
    url_github_dnsproxy = "https://github.com/AdguardTeam/dnsproxy"
    lists_urls = [url_github_dnsproxy, url_golang]
    dict_system_information = get_system_information()
    lists_urls = get_retry_requests_html(lists_urls)
    dict_github = get_retry_requests_github(lists_urls)
    lists_golang = get_retry_requests_golang(lists_urls)
    dict_download = get_link_golang_and_github(dict_system_information, dict_github, lists_golang)
    download(dict_download)

if __name__ == "__main__":
    main()
