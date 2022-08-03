#!/bin/bash
set -eu

memed start --rpc.laddr tcp://0.0.0.0:26657 --log_level=info --trace # --trace # does not work anymore: --log_level="main:info,state:debug,*:error"
