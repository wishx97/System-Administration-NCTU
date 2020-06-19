import os
import sys
import yaml
import schedule
import signal

from subprocess import call


class GracefulKiller:
    reload_config = False

    def __init__(self):
        signal.signal(signal.SIGHUP, self.exit_gracefully)

    def exit_gracefully(self, signum, frame):
        print("Received reload signal")
        self.reload_config = True


class zBackupd:
    def __init__(self):
        self.is_background = False
        self.pid_path = "/var/run/zbackup.pid"
        self.config_path = "/usr/local/etc/zbackupd.yaml"
        self.log_path = open("/var/log/zbackup.log", "a")

    def parse_arg(self):
        mark = 0
        for i in range(1, len(sys.argv)):
            if mark == 2:
                self.config_path = sys.argv[i]
                mark = 0
                continue
            elif mark == 3:
                self.pid_path = sys.argv[i]
                mark = 0
                continue
            if sys.argv[i] == "-d":
                self.is_background = True
            elif sys.argv[i] == "-c":
                mark = 2
            elif sys.argv[i] == "-p":
                mark = 3
            else:
                print("Invalid argument {}".format(sys.argv[i]))
                return False

    def parse_yaml(self):
        try:
            with open(self.config_path, 'r') as f:
                doc = yaml.load(f)
        except Exception as e:
                print("Configuration file not found")
                return False
        doc = doc.get("backup")
        for i in doc:
            if i.get("enabled") is not False:
                dataset_name = i.get("dataset")
                rotation = i.get("rotation")
                if rotation is None:
                    call(["zbackup", dataset_name], stdout=self.log_path)
                else:
                    call(["zbackup", dataset_name, str(rotation)], stdout=self.log_path)
                period = i.get("period")
                time_unit = period[-1]
                time_period = int(period[0:len(period)-1])
                if time_unit == "s":
                    schedule.every(time_period).seconds.do(self.run_zbackup, dataset_name, rotation)
                elif time_unit == "m":
                    schedule.every(time_period).minutes.do(self.run_zbackup, dataset_name, rotation)
                elif time_unit == "h":
                    schedule.every(time_period).hours.do(self.run_zbackup, dataset_name, rotation)
                elif time_unit == "d":
                    schedule.every(time_period).days.do(self.run_zbackup, dataset_name, rotation)
                elif time_unit == "w":
                    schedule.every(time_period).weeks.do(self.run_zbackup, dataset_name, rotation)
                else:
                    print("Config file error")
                    return False
        killer = GracefulKiller()
        while not killer.reload_config:
            schedule.run_pending()

    def run_zbackup(self, dataset_name, rotation=-1):
        if rotation == -1:
            call(["zbackup", dataset_name], stdout=self.log_path)
        else:
            call(["zbackup", dataset_name, str(rotation)], stdout=self.log_path)


if __name__ == "__main__":
    c1 = zBackupd()
    if c1.parse_arg() and c1.is_background and os.fork():
        sys.exit()

        # write to pid file
        with open(c1.pid_path, "w") as f:
            f.write(str(os.getpid()))
        while True:
            c1.parse_yaml()
            schedule.clear()
            