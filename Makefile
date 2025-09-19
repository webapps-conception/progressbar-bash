# Variables
BUMP_SCRIPT := ./bump.sh
BRANCH := main

.PHONY: bump release simulate test demo clean

bump:
	$(BUMP_SCRIPT) $${TYPE:-patch}

release:
	$(BUMP_SCRIPT) $${TYPE:-patch}
	git push origin $(BRANCH) --tags

simulate:
	$(BUMP_SCRIPT) $${TYPE:-patch} --dry-run

test:
	bash test_progressbar.sh

demo:
	bash make-demo.sh

clean:
	rm -f demo.gif
