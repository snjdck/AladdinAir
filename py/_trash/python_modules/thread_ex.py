import _thread

start_new_thread = _thread.start_new_thread

def thread_packet_send(handler, queue):
	while True:
		handler(queue.get())

def thread_packet_recv(handler, queue):
	while True:
		handler(*queue.get())

def start_packet_send_thread(handler, queue):
	start_new_thread(thread_packet_send, (handler, queue))

def start_packet_recv_thread(handler, queue):
	start_new_thread(thread_packet_recv, (handler, queue))