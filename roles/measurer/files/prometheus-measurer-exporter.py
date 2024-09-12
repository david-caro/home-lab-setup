#!/usr/bin/env python3
import adafruit_dht
import board
import click
import time
from prometheus_client import Gauge, start_http_server


temperature_stat = Gauge("temperature", "Room temperature", ["room"])
humidity_stat = Gauge("humidity", "Room humidity", ["room"])


@click.command()
@click.option("--port", type=int, default=8000)
def main(port: int) -> None:
    device = adafruit_dht.DHT22(board.pin.D4)
    start_http_server(port)
    while True:
        try:
            temperature = device.temperature
            humidity = device.humidity
            if not temperature and not humidity:
                raise Exception(
                    f"Failed to read temp {temperature} or humidity {humidity}"
                )

            temperature_stat.labels("office").set(temperature)
            humidity_stat.labels("office").set(humidity)
            time.sleep(60)

        except Exception as error:
            print(f"Got error: {error}")
            time.sleep(1)


if __name__ == "__main__":
    main()
