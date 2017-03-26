# -*- coding: utf-8 -*-
import os

from network.server import TCPConnectionDelegage
from utils.logger import logger
from protobuf import pb_helper
from protobuf import message_common_pb2

class DirSession(TCPConnectionDelegage):
    def __init__(self):
        TCPConnectionDelegage.__init__(self)
    def on_receive(self, data):
        logger().i("receive from %s", str(self.address))
        msg = pb_helper.BytesToMessage(data)
        if isinstance(msg, message_common_pb2.DirInfo):
            self._send_dirinfo()
        else:
            self.close()
    def _send_dirinfo(self):
        path = os.path.split(os.path.realpath(__file__))[0].replace("\\", "/")
        msg = message_common_pb2.DirInfo()
        filename = path + "/bin/version.xml"
        with open(filename,"rb") as fin:
            data = fin.read()
            msg.version = data
            fin.close()
        filename = path + "/bin/version.txt"
        with open(filename, "rb") as fin:
            data = fin.read()
            msg.patches = data
            fin.close()
        buff = pb_helper.MessageToSendBytes(msg)
        logger().i("send dirinfo to %s", str(self.address))
        self.send(buff)
    def on_write_complete(self):
        #self.close()
        pass