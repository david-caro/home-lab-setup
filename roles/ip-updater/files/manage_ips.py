#!/usr/bin/env python3

import requests
from pathlib import Path
from requests.auth import HTTPBasicAuth
import logging
import subprocess
import click

SUBDOMAINS = [
    "emby",
    "eopsin",
    "expenses",
    "grafana",
    "homeassistant",
    "ssh",
    "fr.ssh",
    "sudo",
    "znc",
    "ceph",
    "media",
    "atuin",
    "skill-media",
]
DOMAINS = [
    "dcaro.es",
    "greyllama.cc",
]
URL_TEMPLATE = "http://www.ovh.com/nic/update?system=dyndns&hostname={subdomain}.{domain}&myip={ip}"


LOGGER = logging.getLogger(__name__)


@click.group()
def main():
    # result = requests.get(URL)
    pass


@main.command()
def get_my_ip_v6():
    result = subprocess.check_output(
        ["dig", "TXT", "+short", "o-o.myaddr.l.google.com", "@ns1.google.com"]
    )
    click.echo(result)


@main.command()
def get_my_ip_v4():
    result = requests.get("http://ifconfig.me")
    click.echo(result.text)


@click.option("--static-ip", default=None)
# @click.option("--user", required=True)
@click.option("--password", required=True)
@main.command()
def update_ips(static_ip, password):
    if not static_ip:
        static_path = Path("./static-ip")
        if static_path.exists():
            my_ip = static_path.open(encoding="utf-8").read().strip()
        else:
            my_ip = requests.get("http://ifconfig.me").text
    else:
        my_ip = static_ip

    for domain in DOMAINS:
        for subdomain in SUBDOMAINS:
            result = requests.get(
                URL_TEMPLATE.format(subdomain=subdomain, ip=my_ip, domain=domain),
                auth=HTTPBasicAuth(f"{domain}-updater", password),
            )
            if result.status_code != 200:
                result.raise_for_status()
            LOGGER.info(f"Refreshed subdomain {subdomain}.{domain}: {result.text}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
