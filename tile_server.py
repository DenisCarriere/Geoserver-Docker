# -*- encoding: utf-8 -*-

import os
from flask import Flask, send_file, jsonify, request
app = Flask(__name__)


@app.route("/<basemap>/<int:zoom>/<int:x>/<int:y><ext>", methods=['GET', 'POST'])
def tms(basemap, zoom, x, y, ext):

    # Convert to Google Maps compatible format
    google_y = (2 ** zoom) - y - 1

    # Tile information
    info = {
        'basemap': basemap,
        'x': x,
        'y': y,
        'google_y': google_y,
        'zoom': zoom,
        'ext': ext
    }
    tile = "/data/tile/{basemap}/{zoom}/{x}/{google_y}{ext}".format(**info)

    # Validate User
    key = request.args.get('api_key')
    if key not in ['123']:
        msg = info
        msg['error'] = 'Invalid Credentials'
        msg['status'] = 401
        return jsonify(msg)

    # Check if Tile Exists
    if not os.path.exists(tile):
        msg = info
        msg['error'] = 'Tile does not exist'
        msg['status'] = 404
        return jsonify(msg)

    # Success
    else:
        return send_file(tile, mimetype='image/png')


if __name__ == "__main__":
    app.run(debug=True)
