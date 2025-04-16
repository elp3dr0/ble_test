
"""
Python script to broadcast waterrower data over BLE and ANT

      PiRowFlo for Waterrower
                                                                 +-+
                                               XX+-----------------+
                  +-------+                 XXXX    |----|       | |
                   +-----+                XXX +----------------+ | |
                   |     |             XXX    |XXXXXXXXXXXXXXXX| | |
    +--------------X-----X----------+XXX+------------------------+-+
    |                                                              |
    +--------------------------------------------------------------+

To begin choose an interface from where the data will be taken from either the S4 Monitor connected via USB or
the Smartrow pulley via bluetooth low energy

Then select which broadcast methode will be used. Bluetooth low energy or Ant+ or both.

e.g. use the S4 connected via USB and broadcast data over bluetooth and Ant+

python3 waterrowerthreads.py -i s4 -b -a
"""

import logging
import logging.config
import threading
from queue import Queue
from collections import deque

from adapters.ble import waterrowerble
import pathlib
import signal

loggerconfigpath = str(pathlib.Path(__file__).parent.absolute()) +'/' +'logging.conf'

logger = logging.getLogger(__name__)
Mainlock = threading.Lock()


class Graceful:

    def __init__(self):
        self.run = True
        signal.signal(signal.SIGINT, self.exit_gracefully)
        signal.signal(signal.SIGTERM, self.exit_gracefully)

    def exit_gracefully(self,signum, frame):
        Mainlock.acquire()
        self.run = False
        logger.info("Quit gracefully program has been interrupt externally - exiting")
        Mainlock.release()


def main():
    logging.config.fileConfig(loggerconfigpath, disable_existing_loggers=False)
    grace = Graceful()

    def BleService(out_q, ble_in_q):
        logger.info("Start BLE Advertise and BLE GATT Server")
        bleService = waterrowerble.main(out_q, ble_in_q)
        bleService()


    # TODO: Switch from queue to deque
    q = Queue()
    ble_q = deque(maxlen=1)
    ant_q = deque(maxlen=1)
    threads = []



    t = threading.Thread(target=BleService, args=(q, ble_q))
    t.daemon = True
    t.start()
    threads.append(t)



    while grace.run:
        for thread in threads:
            if grace.run == True:
                thread.join(timeout=10)
                if not thread.is_alive():
                    logger.info("Thread died - exiting")
                    return

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("code has been shutdown")

