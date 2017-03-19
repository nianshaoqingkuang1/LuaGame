# -*- coding: utf-8 -*-
import struct

from protobuf import message_common_pb2


def import_driver(drivers, preferred=None):
    """Import the first available driver or preferred driver.
    """
    if preferred:
        drivers = [preferred]

    for d in drivers:
        try:
            return __import__(d, None, None, ['x'])
        except ImportError:
            pass
    raise ImportError("Unable to import " + " or ".join(drivers))

def getMessage(full_name):
    modulename_, class_ = full_name.rsplit('.', 1)
    module = import_driver(["protobuf."+modulename_+"_pb2"])
    class_ = getattr(module, class_)
    return class_


def debug_bytes(data):
    tstr = ""
    for i in range(len(data)):
        sep = ',' if i <len(data)-1 else ''
        tstr = tstr + hex(ord(data[i])) + sep
    return tstr

def BytesToMessage(data):
    try:
        body = data[2:]
        basemsg = message_common_pb2.Message()
        basemsg.ParseFromString(body)
        cls = getMessage(basemsg.message_name)
        msg = cls()
        msg.ParseFromString(basemsg.message_body)
        return msg
    except Exception as e:
        print e

def MessageToSendBytes(message):
    meta = message_common_pb2.Message()
    meta.message_name = message.DESCRIPTOR.full_name
    meta.message_body = message.SerializeToString()
    body = meta.SerializeToString()
    bodylen = len(body)
    header = struct.pack('H', bodylen)
    return header+body

