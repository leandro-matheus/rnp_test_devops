import os
import time
from datetime import datetime
import psycopg2
from ping3 import ping
import requests

DB_HOST     = os.getenv('DB_HOST', 'localhost')
DB_PORT     = int(os.getenv('DB_PORT', 5432))
DB_NAME     = os.getenv('DB_NAME', 'monitor_db')
DB_USER     = os.getenv('DB_USER', 'monitor')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'monitor_pass')
TARGETS     = os.getenv('TARGET_HOSTS', 'google.com,youtube.com,rnp.br').split(',')
INTERVAL    = int(os.getenv('INTERVAL', 60))

def get_conn():
    return psycopg2.connect(
        host=DB_HOST, port=DB_PORT,
        dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD
    )

def do_ping(host):
    # RTT único (ms)
    rtt = ping(host, unit='ms')
    # Simula 4 tentativas para cálculo de perda
    sent = 4
    recv = 0
    for _ in range(sent):
        if ping(host, timeout=2):
            recv += 1
    loss = (sent - recv) / sent * 100
    return rtt, loss

def do_http(host):
    url = f'https://{host}'
    start = time.time()
    try:
        resp = requests.get(url, timeout=10)
        elapsed = (time.time() - start) * 1000  # ms
        return elapsed, resp.status_code
    except:
        return None, None

def main():
    conn = get_conn()
    cur = conn.cursor()
    while True:
        now = datetime.utcnow()
        for host in TARGETS:
            rtt, loss = do_ping(host)
            cur.execute(
                "INSERT INTO ping_results (timestamp, host, rtt_ms, packet_loss) VALUES (%s, %s, %s, %s)",
                (now, host, rtt, loss)
            )
            rt, status = do_http(host)
            cur.execute(
                "INSERT INTO http_results (timestamp, host, response_time_ms, status_code) VALUES (%s, %s, %s, %s)",
                (now, host, rt, status)
            )
        conn.commit()
        time.sleep(INTERVAL)

if __name__ == '__main__':
    main()
