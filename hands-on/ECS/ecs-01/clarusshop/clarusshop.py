from flask import Flask

app = Flask(__name__)

@app.route('/')
def storefront():
    return '<h1>Welcome to clarusshop!</h1><h2>/account</h2><h2>/inventory</h2><h2>/shipping</h2>'

@app.route('/account')
def account():
    return '<h1>This is your account.</h1>'

@app.route('/inventory')
def inventory():
    return '<h1>This is inventory service</h1>'

@app.route('/shipping')
def shipping():
    return '<h1>This is shipping service</h1>'

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=80)