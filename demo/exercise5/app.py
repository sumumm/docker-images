from flask import Flask
import redis

app = Flask(__name__)
r = redis.Redis(host='redis', port=6379, decode_responses=True)

@app.route('/ping')
def ping():
    count = r.incr('count')
    return f'PONG {count}', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
