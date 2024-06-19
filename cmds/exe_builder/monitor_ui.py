import tkinter as tk
import threading
import time
import subprocess
import re
import os
import sys

class GridThread(threading.Thread):
    def __init__(self, text_widget, device_serial, device_index):
        super().__init__()
        self.text_widget = text_widget
        self.device_serial = device_serial
        self.device_index = device_index
        self.command_returncode=0
        self.stopped = threading.Event()

    def remove_ansi_escape(self, text):
        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')
        return ansi_escape.sub('', text)

    def remove_extra_newlines(self, text):
        return text.replace("\n\n", "\n")

    def remove_id_time_column(self, text):
        remove_res = [' '.join(line.split()[0:1] + ["|| "] + line.split()[5:]) for line in text.split('\n')]
        return '\n'.join(remove_res)
    
    def get_testing_status(self):
        command = f"{adb_path} -s {self.device_serial} shell /etc/init.d/xq3_testing info"
        command_process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = command_process.communicate()
        test_info = stdout.decode('utf-8')

        command = f"{adb_path} -s {self.device_serial} shell /etc/init.d/xq3_testing status"
        command_process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = command_process.communicate()
        test_status = stdout.decode('utf-8')

        command = f"{adb_path} -s {self.device_serial} shell /etc/init.d/xq3_testing result"
        command_process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = command_process.communicate()
        test_result = stdout.decode('utf-8')

        if "stop" in test_status:
            return "", test_result
        
        return ("", self.remove_id_time_column(test_result)) if test_info == "" else ("_"+test_info, self.remove_id_time_column(test_result))

    def update_gui(self, result_output):
        self.text_widget.after(0, lambda: self._update_gui(result_output))

    def _update_gui(self, result_output):
        self.text_widget.configure(state='normal')
        self.text_widget.delete("1.0", tk.END)
        self.text_widget.insert(tk.END, str(result_output))
        self.text_widget.configure(state='disabled')

    def run(self):
        time.sleep(5)
        while not self.stopped.is_set():
            if self.device_serial == "-":
                continue
            try:
                test_info, test_result = self.get_testing_status()

                
                label_name = f"label_{self.device_index}"
                label = self.text_widget.master.nametowidget(label_name)
                label.configure(text=(self.device_serial+test_info).rstrip())

                #filtered_output = self.remove_ansi_escape(stdout_output)
                #monitor_result_output = self.remove_extra_newlines(filtered_output)
                #final_output = self.remove_id_time_column(monitor_result_output)
                self.update_gui(test_result)
            except subprocess.TimeoutExpired:
                pass
            time.sleep(5)

    def stop(self):
        self.stopped.set()

def get_grid_label(device_serial):
    res_str=""

    if device_serial == "-":
        return "-"


    return device_serial

def fill_grid():
    threads = []
    device_index = 0
    for i in range(4):
        root.grid_rowconfigure(i+1, weight=1, minsize=150)
        root.grid_columnconfigure(i, weight=1, minsize=150)
        for j in range(4):
            frame = tk.Frame(root, bg="white")
            frame.grid(row=i+1, column=j, padx=5, pady=5, sticky="nsew")
            #label = tk.Label(frame, text=get_grid_label(devices_list_array[device_index]), font=("Times New Roman", 12), anchor="center")
            label = tk.Label(frame, text=get_grid_label(devices_list_array[device_index]), font=("Times New Roman", 12), anchor="center", name=f"label_{device_index}")
            label.pack()
            text = tk.Text(frame, height=5, width=15)
            text.config(font=("Times New Roman", 10))
            text.config(spacing1=5)
            text.config(spacing2=2)
            text.pack(fill="both", expand=True)
            thread = GridThread(text, devices_list_array[device_index], device_index)
            thread.setDaemon(True)
            thread.start()
            threads.append(thread)
            device_index += 1
    return threads

def on_close():
    for thread in threads:
        thread.stop()
    root.destroy()

root = tk.Tk()
root.geometry("800x600")
root.minsize(800, 600)
root.title("Throughput Monitor")
root.grid_propagate(False)

root_path = sys.argv[1]
#configs_path = os.path.join(root_path, "configs")
adb_path = os.path.join(root_path, "adb_tool", "adb")

devices_list_array = ['-'] * 16
cur_adb_devices = sys.argv[2:]
devices_list_array[:len(cur_adb_devices)] = cur_adb_devices

threads = fill_grid()

root.protocol("WM_DELETE_WINDOW", on_close)
root.mainloop()