SHELL := /bin/bash
VM_USER ?= vm-admin
DOCKER ?= none
PARALLEL ?= 0
.DEFAULT_GOAL := help

.PHONY: help test lint macos-install macos-create macos-open macos-bootstrap \
	macos-doctor linux-create linux-gui linux-shell linux-login linux-doctor \
	linux-start linux-stop linux-snapshot linux-destroy linux-harnesses create \
	gui shell login doctor start stop snapshot destroy ssh-config harnesses

help:
	@printf '%s\n' \
		'Agent Devbox' \
		'' \
		'macOS full-UI profile:' \
		'  make macos-install' \
		'  make macos-create [DOCKER=none|remote] [PARALLEL=0|1]' \
		'  make macos-bootstrap HOST=<guest-ip> [VM_USER=vm-admin] [DOCKER=none|remote]' \
		'  make macos-doctor [HOST=<guest-ip>] [DOCKER=none|remote]' \
		'  make macos-open' \
		'' \
		'Ubuntu profile:' \
		'  make linux-create' \
		'  make linux-gui SESSION=dev|codex|claude' \
		'  make linux-shell' \
		'  make linux-doctor' \
		'' \
		'Development:' \
		'  make test' \
		'  make lint'

test:
	./tests/test.sh

lint:
	./tests/lint.sh

macos-install:
	./bin/macos-install-host

macos-create:
	MACOS_DOCKER_MODE="$(DOCKER)" MACOS_PARALLEL_VMS="$(PARALLEL)" ./bin/macos-create

macos-open:
	./bin/macos-open

macos-bootstrap:
	MACOS_VM_HOST="$(HOST)" MACOS_VM_USER="$(VM_USER)" MACOS_DOCKER_MODE="$(DOCKER)" ./bin/macos-bootstrap

macos-doctor:
	MACOS_VM_HOST="$(HOST)" MACOS_VM_USER="$(VM_USER)" MACOS_DOCKER_MODE="$(DOCKER)" ./bin/macos-doctor

linux-create: create

linux-gui: gui

linux-shell: shell

linux-login: login

linux-doctor: doctor

linux-start: start

linux-stop: stop

linux-snapshot: snapshot

linux-destroy: destroy

linux-harnesses: harnesses

create:
	./bin/create

gui:
	./bin/gui "$(SESSION)"

shell:
	./bin/connect

login:
	./bin/login "$(PROVIDER)"

doctor:
	./bin/doctor

start:
	./bin/start

stop:
	./bin/stop

snapshot:
	./bin/snapshot

destroy:
	./bin/destroy

ssh-config:
	./bin/ssh-config

harnesses:
	./bin/install-host-ssh-config
