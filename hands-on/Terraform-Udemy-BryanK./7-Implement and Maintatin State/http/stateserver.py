#!/usr/bin/python3

import flask
import flask_restful
import json
import logging
import os

app = flask.Flask(__name__)
api = flask_restful.Api(app)


@app.before_request
def log_request_info():
    headers = []
    for header in flask.request.headers:
        headers.append('%s = %s' % (header[0], header[1]))

    body = flask.request.get_data().decode('utf-8').split('\n')

    app.logger.debug(('%(method)s for %(url)s...\n'
                      '    Header -- %(headers)s\n'
                      '    Body -- %(body)s\n')
                     % {
        'method': flask.request.method,
        'url': flask.request.url,
        'headers': '\n    Header -- '.join(headers),
        'body': '\n           '.join(body)
    })


class Root(flask_restful.Resource):
    def get(self):
        resp = flask.Response(
            '<html><body>Oh, hello</body></html>',
            mimetype='text/html')
        resp.status_code = 200
        return resp


class StateStore(object):
    def __init__(self, path):
        self.path = path
        os.makedirs(self.path, exist_ok=True)

    def _log(self, id, op, data):
        log_file = os.path.join(self.path, id) + '.log'
        with open(log_file, 'a') as f:
            f.write('%s: %s\n' %(op, data))


    def get(self, id):
        file = os.path.join(self.path, id)
        if os.path.exists(file):
            with open(file) as f:
                d = f.read()
                self._log(id, 'state_read', {})
                return json.loads(d)
        return None

    def put(self, id, info):
        file = os.path.join(self.path, id)
        data = json.dumps(info, indent=4, sort_keys=True)
        with open(file, 'w') as f:
            f.write(data)
            self._log(id, 'state_write', data)

    def lock(self, id, info):
        # NOTE(mikal): this is racy, but just a demo
        lock_file = os.path.join(self.path, id) + '.lock'
        if os.path.exists(lock_file):
            # If the lock exists, it should be a JSON dump of information about
            # the lock holder
            with open(lock_file) as f:
                l = json.loads(f.read())
            return False, l

        data = json.dumps(info, indent=4, sort_keys=True)
        with open(lock_file, 'w') as f:
            f.write(data)
        self._log(id, 'lock', data)
        return True, {}

    def unlock(self, id, info):
        lock_file = os.path.join(self.path, id) + '.lock'
        if os.path.exists(lock_file):
            os.unlink(lock_file)
            self._log(id, 'unlock', json.dumps(info, indent=4, sort_keys=True))
            return True
        return False


state = StateStore('.stateserver')


class TerraformState(flask_restful.Resource):
    def get(self, tf_id):
        s = state.get(tf_id)
        if not s:
            flask.abort(404)
        return s

    def post(self, tf_id):
        print(flask.request.form)
        s = state.put(tf_id, flask.request.json)
        return {}


class TerraformLock(flask_restful.Resource):
    def put(self, tf_id):
        success, info = state.lock(tf_id, flask.request.json)
        if not success:
            flask.abort(423, info)
        return info

    def delete(self, tf_id):
        if not state.unlock(tf_id, flask.request.json):
            flask.abort(404)
        return {}


api.add_resource(Root, '/')
api.add_resource(TerraformState, '/terraform_state/<string:tf_id>')
api.add_resource(TerraformLock, '/terraform_lock/<string:tf_id>')


if __name__ == '__main__':
    # Note this is not run with the flask task runner...
    app.log = logging.getLogger('werkzeug')
    app.log.setLevel(logging.DEBUG)
    app.run(host='0.0.0.0', debug=True)