# -*- coding: utf-8 -*-
import threading

from tornado import ioloop
from tornado.tcpserver import TCPServer
from tornado import stack_context
from tornado.escape import native_str

class TCPConnectionDelegage(object):
	def on_connect(self):
		pass
	def on_timeout(self):
		pass
	def on_receive(self,data):
		pass
	def on_write_complete(self):
		pass
	def on_close(self):
		pass
	def send(self,data):
		if not self.stream.closed():
			self.stream.write(data, stack_context.wrap(self.on_write_complete))
		else:
			raise "connection is broken."
	def __init__(self):
		self.stream = None
		self.address = None
	def close(self):
		if self.stream is not None:
			self.stream.close()

class TCPConnection(object):
	def __init__(self, stream, address, delegate = TCPConnectionDelegage()):
		self.delegate = delegate
		self.stream = stream
		self.address_family = stream.socket.family
		self.delegate.stream = stream
		self.delegate.address = address
		self.delegate.on_connect()
		self._message_callback = stack_context.wrap(self._on_receive)
		self.stream.set_close_callback(self._on_connection_close)
		self.stream.read_bytes(2048, self._message_callback, partial=True)

	def _on_timeout(self):
		self.delegate.on_timeout()

	def _on_receive(self, data):
		try:
			self.delegate.on_receive(data)
			self.stream.read_bytes(2048, self._message_callback, partial=True)
		except Exception as ex:
			raise ex

	def _on_connection_close(self):
		self.delegate.on_close()

class TCPBaseServer(TCPServer):
	def __init__(self, io_loop=None, handle=None, **kwargs):
		TCPServer.__init__(self, io_loop=io_loop, **kwargs)
		self.handle = handle

	def handle_stream(self, stream, address):
		if self.handle is not None:
			delegate = self.handle()
			assert isinstance(delegate, TCPConnectionDelegage),"delegate must be implement TCPConnectionDelegage"
			TCPConnection(stream, address, delegate)
		else:
			TCPConnection(stream, address, TCPConnectionDelegage())

	def run(self, port):
		self.listen(port)


def main():
	server = TCPBaseServer()
	server.listen(8001)
	print "server runing at %d" % 8001
	ioloop.IOLoop.instance().start()

if __name__ == "__main__":
	try:
		main()
	except Exception as ex:
		print "Ocurred Exception: %s" % str(ex)
		quit()
