#!/bin/sh

iverilog decoder.t.v -o /tmp/decoder.t.o && /tmp/decoder.t.o
