"""Temporary Penpot MCP transport. Credentials live only in process memory."""
import base64
import json
import os
from pathlib import Path
import sys
import urllib.error
import urllib.request

token = os.environ.pop('PENPOT_SESSION_KEY')
url = 'https://design.penpot.app/mcp/stream?userToken=' + token
session = None
sequence = 0

def request(method, params=None, notification=False):
    global sequence, session
    sequence += 1
    payload = {'jsonrpc': '2.0', 'method': method}
    if not notification:
        payload['id'] = sequence
    if params is not None:
        payload['params'] = params
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream', 'User-Agent': 'Mozilla/5.0'}
    if session:
        headers['Mcp-Session-Id'] = session
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers)
    with urllib.request.urlopen(req, timeout=90) as response:
        session = response.headers.get('Mcp-Session-Id', session)
        body = response.read().decode()
        if not body:
            return None
        if any(line.startswith('data: ') for line in body.splitlines()):
            events = [json.loads(line[6:]) for line in body.splitlines() if line.startswith('data: ') and line[6:].strip()]
            return next(event for event in events if event.get('id') == sequence)
        return json.loads(body)

request('initialize', {'protocolVersion': '2024-11-05', 'capabilities': {}, 'clientInfo': {'name': 'authorized-design-session', 'version': '1.0'}})
request('notifications/initialized', notification=True)
print(json.dumps({'ready': True}), flush=True)
for line in sys.stdin:
    try:
        command = json.loads(line)
        if command.get('close'):
            break
        if command.get('list'):
            result = request('tools/list')['result']['tools']
            print(json.dumps({'tools': [{'name': t['name'], 'inputSchema': t.get('inputSchema')} for t in result]}), flush=True)
            continue
        arguments = command.get('arguments', {})
        if command.get('code_file'):
            arguments['code'] = Path(command['code_file']).read_text()
        if command.get('upload_image'):
            encoded = base64.b64encode(Path(command['upload_image']).read_bytes()).decode()
            mime = 'image/jpeg' if Path(command['upload_image']).suffix == '.jpg' else 'image/png'
            arguments['code'] = "storage.alleyImage = await penpot.uploadMediaData('Vending alley concept', Uint8Array.from(atob(" + json.dumps(encoded) + "), c=>c.charCodeAt(0)), " + json.dumps(mime) + "); return {uploaded:true};"
        result = request('tools/call', {'name': command['name'], 'arguments': arguments})
        if command.get('save_png'):
            for item in result.get('result', {}).get('content', []):
                if item.get('type') == 'image':
                    Path(command['save_png']).write_bytes(base64.b64decode(item['data']))
                    item['data'] = '[saved image]'
        print(json.dumps(result, ensure_ascii=False), flush=True)
    except urllib.error.HTTPError as error:
        print(json.dumps({'error': error.code, 'message': error.read(1000).decode().replace(token, '[redacted]')}), flush=True)
    except Exception as error:
        print(json.dumps({'error': type(error).__name__, 'message': str(error).replace(token, '[redacted]')}), flush=True)
