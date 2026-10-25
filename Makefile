.PHONY: test test-unit test-bdd bdd

test: test-unit test-bdd

test-unit:
	@sh tests/test_init.sh

test-bdd:
	@sh tests/bdd/test_bdd.sh

bdd: test-bdd
