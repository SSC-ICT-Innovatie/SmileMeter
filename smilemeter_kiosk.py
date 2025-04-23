# SmileMeter: Interactive Feedback Kiosk with USB buttons and summary view

import tkinter as tk
from datetime import datetime
import csv
import os
from collections import Counter
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import evdev
import threading

# --- CONFIGURATION ---
EMOJIS = ["🙂", "😐", "😕"]
LABELS = ["Happy", "Neutral", "Unhappy"]
FILENAME = "smilemeter_votes.csv"
DEVICE_PATHS = [
    "/dev/input/event0",  # Map each USB button to its respective event file
    "/dev/input/event1",
    "/dev/input/event2"
]
KEY_CODES = [28, 57, 14]  # Example key codes: Enter, Space, Backspace (customize per device)

# --- FUNCTIONS ---
def log_vote(choice_idx):
    with open(FILENAME, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datetime.now().isoformat(), LABELS[choice_idx]])

def on_vote(choice_idx):
    log_vote(choice_idx)
    for i in range(3):
        buttons[i].config(bg="SystemButtonFace")
    buttons[choice_idx].config(bg="lightgreen")
    message_label.config(text=f"Thanks for your feedback: {EMOJIS[choice_idx]}", fg="green")
    root.after(2000, reset_display)

def reset_display():
    message_label.config(text="How was your experience?", fg="black")
    for btn in buttons:
        btn.config(bg="SystemButtonFace")

def read_votes():
    if not os.path.exists(FILENAME):
        return []
    with open(FILENAME, newline='') as file:
        reader = csv.reader(file)
        return [row[1] for row in reader]

def show_summary():
    votes = read_votes()
    counts = Counter(votes)
    data = [counts.get(label, 0) for label in LABELS]

    summary_window = tk.Toplevel(root)
    summary_window.title("Vote Summary")
    fig, ax = plt.subplots()
    ax.bar(LABELS, data, color='skyblue')
    ax.set_title("Feedback Summary")
    ax.set_ylabel("Votes")

    canvas = FigureCanvasTkAgg(fig, master=summary_window)
    canvas.draw()
    canvas.get_tk_widget().pack()

def input_listener():
    devices = [evdev.InputDevice(path) for path in DEVICE_PATHS]
    for device in devices:
        device.grab()
    while True:
        for dev_idx, device in enumerate(devices):
            for event in device.read_loop():
                if event.type == evdev.ecodes.EV_KEY and event.value == 1:  # Key press
                    if event.code == KEY_CODES[dev_idx]:
                        root.after(0, lambda idx=dev_idx: on_vote(idx))

# --- GUI SETUP ---
root = tk.Tk()
root.title("SmileMeter Feedback")
root.attributes('-fullscreen', True)

message_label = tk.Label(root, text="How was your experience?", font=("Arial", 24))
message_label.pack(pady=40)

frame = tk.Frame(root)
frame.pack(expand=True)

buttons = []
for idx, emoji in enumerate(EMOJIS):
    btn = tk.Button(frame, text=emoji, font=("Arial", 60), width=4, height=2,
                    command=lambda i=idx: on_vote(i))
    btn.grid(row=0, column=idx, padx=40)
    buttons.append(btn)

summary_btn = tk.Button(root, text="View Summary", command=show_summary, font=("Arial", 16))
summary_btn.pack(pady=20)

# Start USB input listener in separate thread
listener_thread = threading.Thread(target=input_listener, daemon=True)
listener_thread.start()

root.mainloop()
