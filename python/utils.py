#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import psutil as ps
import re
import argparse
import numpy


def get_process_by_command(name):
    result = []
    process_list = ps.get_process_list()
    for p in process_list:
        str = ' '
        str = str.join(p.cmdline)
        if (re.search(name, str)):
            result.append(p)
    return result


def get_args():
    parser = argparse.ArgumentParser(
        description='description of the tool.')
    parser.add_argument(
        '-c', '--cmdline', help='commmand line')
    args = parser.parse_args()
    return vars(args)

def get_hex_string(hex):
    hex_str_list = hex.split(' ')
    hex_number_list = []
    for hex_str in hex_str_list:
        hex_number_list.append(int('0x'+ hex_str, 16))
    return hex_number_list

if (__name__ == '__main__'):
    pass
    #args = get_args()
    #ps = get_process_by_command(args['cmdline'])
    #for p in ps:
    #   print str(p.pid) + '        ' + ''.join(p.cmdline)
    hex_number_list = get_hex_string('45 00 00 1C A9 6E 00 00 40 01 11 72 C0 A8 1F 01')
    hex_sum = numpy.sum(hex_number_list)
    print bin(hex_sum)
    hex_sum = (hex_sum >> 16) + (hex_sum & 0xffff)
    print bin(hex_sum)
    hex_sum = ~ hex_sum
    print bin(hex_sum)
    a = (((hex_sum>>8)&0xff)|hex_sum<<8) & 0xffff
    print a
    print hex(a)

