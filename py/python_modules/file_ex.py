import json

def load_json(path):
	with open(path) as f:
		return json.load(f)

def load_socket_address(path, host_key, port_key):
	config = load_json(path)
	return (config[host_key], config[port_key])
