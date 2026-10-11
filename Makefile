.PHONY: all test
all:
	python3 scripts/build.py
test: all
	python3 scripts/test.py
