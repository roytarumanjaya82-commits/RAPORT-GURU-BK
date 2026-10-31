"""Server lokal aplikasi Raport BK. Hanya menjawab dari komputer ini."""
import os
import socket
import subprocess
import sys
import threading
import webbrowser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

HOST = "127.0.0.1"
PORT = 8787


def folder_aplikasi():
    if getattr(sys, "frozen", False):
        return sys._MEIPASS
    return os.path.dirname(os.path.abspath(__file__))


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {
        **getattr(SimpleHTTPRequestHandler, "extensions_map", {}),
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".css": "text/css",
        ".html": "text/html; charset=utf-8",
        ".json": "application/json",
        ".svg": "image/svg+xml",
        ".png": "image/png",
        ".ico": "image/x-icon",
        ".csv": "text/csv; charset=utf-8",
    }

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt, *args):
        code = str(args[1]) if len(args) > 1 else ""
        if code.startswith("2"):
            return
        super().log_message(fmt, *args)


def port_bebas():
    probe = socket.socket()
    try:
        probe.bind((HOST, PORT))
    except OSError:
        return False
    finally:
        probe.close()
    return True


def buka_peramban(url):
    kandidat = [
        os.path.expandvars(r"%ProgramFiles%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%LocalAppData%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"),
        os.path.expandvars(r"%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"),
    ]
    for jalur in kandidat:
        if os.path.isfile(jalur):
            subprocess.Popen([jalur, url])
            return
    webbrowser.open(url)


def main():
    if os.name == "nt":
        try:
            import ctypes
            ctypes.windll.kernel32.SetConsoleTitleW("Raport BK SMP Muhammadiyah 22")
        except Exception:
            pass
    os.chdir(folder_aplikasi())
    url = f"http://{HOST}:{PORT}/"
    if not port_bebas():
        buka_peramban(url)
        return
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    threading.Timer(0.6, lambda: buka_peramban(url)).start()
    print("Raport BK SMP Muhammadiyah 22 Setiabudi Pamulang", flush=True)
    print(f"Aplikasi siap di {url}", flush=True)
    print("Jangan tutup jendela ini selama raport dipakai.", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()


if __name__ == "__main__":
    main()
