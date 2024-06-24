import serial
import serial.tools.list_ports as port_list
import re
import time
import threading
from enum import Enum
import os

class DeviceStatus(Enum):
    nocomport = 1
    disconnect = 2
    connect = 3

def GetEtsPorts():
    ports = list(port_list.comports())
    etsPortsTmp = (str(p) for p in ports if 'ETS' in str(p))
    etsPorts = [re.search(r'COM\d+', port).group() for port in etsPortsTmp]
    return etsPorts

def RunCmd(ser, port, command, read_size=64):
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    try:
        ser.write(command.encode())
    except Exception as e:
        return ""
    response = ser.read(read_size).decode('utf-8')
    return response

class MonitorThread(threading.Thread):
    def __init__(self, comPort):
        super().__init__()
        self.ser = serial.Serial(port=port, baudrate=115200, bytesize=8, parity='N', stopbits=2, timeout=1, rtscts=False, dsrdtr=False, write_timeout=1)
        self.imsi=self.RunCmdToGetImei()
        self.comPort = comPort
        self.deviceStatus = DeviceStatus.disconnect
        self.dlTput = 0
        self.ulTput = 0

    def run(self):
        while True:
            etsPorts = GetEtsPorts()

            if self.comPort not in etsPorts:
                self.deviceStatus = DeviceStatus.nocomport
                time.sleep(1)
                continue

            output = RunCmd(self.ser, port, "AT+EDMFAPP=6,4\r", 128)
            if output == "":
                time.sleep(1)
                continue
            
            outputSplitLinesArray = output.split('\n')
            if len(outputSplitLinesArray) < 3:
                time.sleep(1)
                continue
            lineTwo = outputSplitLinesArray[2]

            lineTwoSplitColon=lineTwo.strip().split(": ")
            if len(lineTwoSplitColon) < 2:
                time.sleep(1)
                continue
            lineTwoValues=lineTwoSplitColon[1]

            lineTwoValuesSplitComma=lineTwoValues.split(',')
            if len(lineTwoValuesSplitComma) < 3:
                time.sleep(1)
                continue
            connectStatus = lineTwoValuesSplitComma[2]

            if connectStatus == "255":
                self.deviceStatus = DeviceStatus.disconnect
                time.sleep(1)
                continue
            else:
                self.deviceStatus = DeviceStatus.connect

                output = RunCmd(self.ser, port, "AT+EDMFAPP=6,13,11\r", 128)
                if output == "":
                    time.sleep(1)
                    continue

                outputSplitLinesArray = output.split('\n')
                if len(outputSplitLinesArray) < 3:
                    time.sleep(1)
                    continue
                lineTwo = outputSplitLinesArray[2]

                lineTwoSplitColon=lineTwo.strip().split(": ")
                if len(lineTwoSplitColon) < 2:
                    time.sleep(1)
                    continue
                lineTwoValues=lineTwoSplitColon[1]

                lineTwoValuesSplitComma=lineTwoValues.split(',')

                self.dlTput = int(lineTwoValuesSplitComma[3])
                self.ulTput = int(lineTwoValuesSplitComma[2])
                time.sleep(1)
                continue

    def RunCmdToGetImei(self):
        output = RunCmd(self.ser, port, "AT+EGMR=0,7\r")
        print(output)
        return output.split('"')[1]

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

# Get ETS COM ports
etsPorts = GetEtsPorts()
print("Initializing ...")

threads = []
devices_num=len(etsPorts)
index=1
for port in etsPorts:
    thread = MonitorThread(port)
    thread.start()
    threads.append(thread)
    initialPrec=(index*100)/devices_num
    os.system('cls' if os.name == 'nt' else 'clear')
    print("Initializing ... " + str(initialPrec) + "%")
    index+=1

while True:
    os.system('cls' if os.name == 'nt' else 'clear')
    totalDTput=0
    totalUTput=0
    for thread in threads:

        printStr = ""
        comport = thread.GetComport()
        imsi = thread.GetImsi()
        
        if imsi == "":
            printStr = f"{comport:<10}"
        else:
            printStr = printStr = f"{imsi} ({comport:<6}): "

        status = thread.GetStatus()
        if status == DeviceStatus.nocomport:
            printStr += f"{'device drop':<30}"
        elif status == DeviceStatus.disconnect:
            printStr += f"{'network disconnect':<30}"
        else:
            totalDTput+=thread.GetDTput()
            totalUTput+=thread.GetUTput()
            printStr += f"DL: {thread.GetDTput():>8.3f} Mbits/s  UL: {thread.GetUTput():>8.3f} Mbits/s"

        print(printStr)

    print(f"\nTotal DL: {totalDTput:.3f} Mbits/s    Total UL: {totalUTput:.3f} Mbits/s")
    time.sleep(5)

        
