import psutil
import time
import sys
import os
import tkinter as tk
from tkinter import messagebox

previous_io_counters = {}

def show_error_message(message):
    root = tk.Tk()
    root.withdraw()
    messagebox.showerror("Erreur de lancement", message)
    root.destroy()

def get_process_info(process_names):
    global previous_io_counters
    cpu_usage = 0
    ram_usage = 0
    disk_read_bytes = 0
    disk_write_bytes = 0
    num_cores = psutil.cpu_count(logical=True) or 1

    for process in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_info', 'io_counters']):
        if process.info['name'] in process_names:
            pid = process.info['pid']
            cpu_usage += process.info['cpu_percent']
            ram_usage += process.info['memory_info'].rss
            if pid in previous_io_counters:
                disk_read_bytes += process.info['io_counters'].read_bytes - previous_io_counters[pid].read_bytes
                disk_write_bytes += process.info['io_counters'].write_bytes - previous_io_counters[pid].write_bytes
            else:
                disk_read_bytes += process.info['io_counters'].read_bytes
                disk_write_bytes += process.info['io_counters'].write_bytes
            previous_io_counters[pid] = process.info['io_counters']

    cpu_usage = cpu_usage / num_cores
    ram_usage = round(ram_usage / (1024 ** 2))
    cpu_usage = round(cpu_usage)
    disk_read_mb = format(disk_read_bytes / (1024 ** 2), '.3f')
    disk_write_mb = format(disk_write_bytes / (1024 ** 2), '.3f')
    return cpu_usage, ram_usage, disk_read_mb, disk_write_mb

def write_info_to_file(process_names):
    while True:
        cpu_usage, ram_usage, disk_read_mb, disk_write_mb = get_process_info(process_names)
        with open(os.path.normpath(sys.argv[1]), 'w') as file:
            file.write(f'{cpu_usage}\n')
            file.write(f'{ram_usage}\n')
            file.write(f'{disk_read_mb}\n')
            file.write(f'{disk_write_mb}\n')
        time.sleep(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        show_error_message("Usage : <log-file-path> <process-name1|process-name2|...>")
        sys.exit()
        
    process_names = sys.argv[2].split('|')
    write_info_to_file(process_names)
