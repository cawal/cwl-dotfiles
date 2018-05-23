#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys


def create_rofi_list():
	print("teste1\ntest2\ntest3");

def process_rofi_output():
	for line in sys.argv:
		print(line)

def execute():
	if len(sys.argv) == 1:
		create_rofi_list()
	else: 
		process_rofi_output()

if __name__ == "__main__":
	execute()
