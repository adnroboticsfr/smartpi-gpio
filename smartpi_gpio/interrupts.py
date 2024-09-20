import os
import time
import select
import threading

class GPIOInterrupts:
    def __init__(self, mode="BCM"):
        super().__init__()
        self.mode = mode
        self.last_event_time = {}
        self.callbacks = {}
        self.poller = select.poll()  # Use select.poll() to monitor GPIO events
        self.running = True
        self.monitor_thread = None

    def _export_pin(self, gpio_pin):
        gpio_path = f"/sys/class/gpio/gpio{gpio_pin}"
        if not os.path.exists(gpio_path):
            try:
                with open("/sys/class/gpio/export", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Error exporting GPIO pin {gpio_pin}: {e}")
                raise

    def _set_direction(self, gpio_pin, direction):
        gpio_dir_path = f"/sys/class/gpio/gpio{gpio_pin}/direction"
        try:
            with open(gpio_dir_path, 'w') as f:
                f.write(direction)
        except OSError as e:
            print(f"Error setting direction for GPIO {gpio_pin}: {e}")
            raise

    def _debounce(self, pin_number, delay=0.2):
        current_time = time.time()
        if pin_number not in self.last_event_time:
            self.last_event_time[pin_number] = current_time
            return True
        if current_time - self.last_event_time[pin_number] > delay:
            self.last_event_time[pin_number] = current_time
            return True
        return False

    def add_interrupt(self, pin_number, edge, callback):
        gpio_pin = pin_number
        self._export_pin(gpio_pin)
        self._set_direction(gpio_pin, "in")

        try:
            with open(f"/sys/class/gpio/gpio{gpio_pin}/edge", 'w') as f:
                f.write(edge)
        except OSError as e:
            print(f"Error configuring interrupt for GPIO {gpio_pin}: {e}")
            raise

        gpio_value_path = f"/sys/class/gpio/gpio{gpio_pin}/value"
        fd = os.open(gpio_value_path, os.O_RDONLY | os.O_NONBLOCK)
        self.poller.register(fd, select.POLLPRI) 

        self.callbacks[fd] = (gpio_pin, callback)

    def remove_interrupt(self, pin_number):
        gpio_pin = pin_number
        try:
            with open(f"/sys/class/gpio/gpio{gpio_pin}/edge", 'w') as f:
                f.write("none")
            gpio_value_path = f"/sys/class/gpio/gpio{gpio_pin}/value"
            fd = os.open(gpio_value_path, os.O_RDONLY)
            self.poller.unregister(fd)  
            os.close(fd) 
            del self.callbacks[fd] 
        except OSError as e:
            print(f"Error removing interrupt for GPIO {gpio_pin}: {e}")
            raise

    def _monitor_loop(self):
        while self.running:
            events = self.poller.poll(1000)  
            for fd, event in events:
                if event & select.POLLPRI:
                    os.lseek(fd, 0, os.SEEK_SET) 
                    state = os.read(fd, 1).strip()
                    gpio_pin, callback = self.callbacks[fd]
                    if state == b'1' and self._debounce(gpio_pin):  
                        callback(gpio_pin)

    def start_monitoring(self):
        if self.monitor_thread is None:
            self.monitor_thread = threading.Thread(target=self._monitor_loop)
            self.monitor_thread.start()

    def stop_monitoring(self):
        self.running = False
        if self.monitor_thread is not None:
            self.monitor_thread.join()
            self.monitor_thread = None

    def cleanup(self):
        self.stop_monitoring()
        for gpio_pin in list(self.callbacks.keys()):
            self.remove_interrupt(gpio_pin)
