import time
import threading
from enum import Enum
import os
import subprocess
import sys

class DeviceStatus(Enum):
    NO_ADB_DEVICES = 1
    NET_DISCONNECT = 2
    NET_CONNECT = 3

def GetAdbDevices():
    command = f"{adbPath} devices"
    result = RunCmd(command)
    if len(result) > 1:
        adb_list = result[1:]
        adb_list = [item.split('\t')[0] for item in adb_list if item]
    else:
        return ""

    return adb_list

def RunCmd(command):
    try:
        subprocess_out = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    except Exception as e:
        return ""
    result = subprocess_out.stdout.split('\n')
    return list(filter(None, result))

class MonitorThread(threading.Thread):
    def __init__(self, adbDevice):
        super().__init__()
        self.adbDevice = adbDevice
        self.imsi=self.RunCmdToGetImei()
        self.deviceStatus = DeviceStatus.NET_DISCONNECT
        self.dlTput = 0
        self.ulTput = 0

    def run(self):
        while True:
            etsPorts = GetAdbDevices()

            if self.adbDevice not in etsPorts:
                self.deviceStatus = DeviceStatus.NO_ADB_DEVICES
                time.sleep(1)
                continue

            command = f"{adbPath} -s {self.adbDevice} shell cat /var/xq3/net_EDMFAPP_6_4"
            result = RunCmd(command)
            if result == "":
                time.sleep(1)
                continue

            if len(result) < 1:
                time.sleep(1)
                continue
            lineOne = result[0]

            lineOneSplitColon=lineOne.strip().split(": ")
            if len(lineOneSplitColon) < 2:
                time.sleep(1)
                continue
            lineOneValues=lineOneSplitColon[1]

            lineTwoValuesSplitComma=lineOneValues.split(',')
            if len(lineTwoValuesSplitComma) < 3:
                time.sleep(1)
                continue
            connectStatus = lineTwoValuesSplitComma[2]

            if connectStatus == "255":
                self.deviceStatus = DeviceStatus.NET_DISCONNECT
                time.sleep(1)
                continue
            else:
                self.deviceStatus = DeviceStatus.NET_CONNECT

                command = f"{adbPath} -s {self.adbDevice} shell cat /var/xq3/net_EDMFAPP_6_13_11"
                result = RunCmd(command)
                if result == "":
                    time.sleep(1)
                    continue

                if len(result) < 1:
                    time.sleep(1)
                    continue
                lineOne = result[0]

                lineOneSplitColon=lineOne.strip().split(": ")
                if len(lineOneSplitColon) < 2:
                    time.sleep(1)
                    continue
                lineTwoValues=lineOneSplitColon[1]

                lineTwoValuesSplitComma=lineTwoValues.split(',')

                self.dlTput = int(lineTwoValuesSplitComma[3])
                self.ulTput = int(lineTwoValuesSplitComma[2])
                time.sleep(1)
                continue

    def RunCmdToGetImei(self):
        command = f"{adbPath} -s {self.adbDevice} shell cat /var/xq3/imei"
        result = RunCmd(command)
        return result[0]

    def GetImsi(self):
        return self.imsi
    
    def GetComport(self):
        return self.comPort
        
    def GetStatus(self):
        return self.deviceStatus

    def GetDTput(self):
        tput = ((self.dlTput/1024.000)*8)/1024.000
        return tput
        
    def GetUTput(self):
        tput = ((self.ulTput/1024.000)*8)/1024.000
        return tput

root_path = sys.argv[1]
adbPath = os.path.join(root_path, "adb_tool", "adb")

# Get ETS COM ports
adbDevices = GetAdbDevices()
print("Initializing ...")

threads = []
devices_num=len(adbDevices)
index=1
for adbDevice in adbDevices:
    thread = MonitorThread(adbDevice)
    thread.start()
    threads.append(thread)
    initialPrec=(index*100)/devices_num
    # os.system('cls' if os.name == 'nt' else 'clear')
    print("Initializing ... " + str(initialPrec) + "%")
    index+=1

while True:
    os.system('cls' if os.name == 'nt' else 'clear')
    totalDTput=0
    totalUTput=0
    for thread in threads:

        printStr = ""
        imsi = thread.GetImsi()
        
        printStr = printStr = f"{imsi}: "

        status = thread.GetStatus()
        if status == DeviceStatus.NO_ADB_DEVICES:
            printStr += f"{'device drop':<30}"
        elif status == DeviceStatus.NET_DISCONNECT:
            printStr += f"{'network disconnect':<30}"
        else:
            totalDTput+=thread.GetDTput()
            totalUTput+=thread.GetUTput()
            printStr += f"DL: {thread.GetDTput():>8.3f} Mbits/s  UL: {thread.GetUTput():>8.3f} Mbits/s"

        print(printStr)

    print(f"\nTotal DL: {totalDTput:.3f} Mbits/s    Total UL: {totalUTput:.3f} Mbits/s")
    time.sleep(5)

        
