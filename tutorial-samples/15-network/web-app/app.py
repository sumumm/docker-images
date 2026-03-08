from flask import Flask
import redis
import socket

app = Flask(__name__)
redis_client = redis.Redis(host='redis-server', port=6379)

@app.route('/')
def hello():
    count = redis_client.incr('hits')
    hostname = socket.gethostname()
    return f'Hello! I have been seen {count} times.\nHostname: {hostname}\n'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000) 