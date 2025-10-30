SHELL := /bin/bash

# ----- Config you may tweak -----
# Name of the executable produced by SwiftPM (change to 'maker' for your project)
PRODUCT ?= maker
# SwiftPM configuration
CONFIG ?= release
# Where SwiftPM builds artifacts (keep local to repo)
BUILDDIR ?= $(shell pwd)/.build

# ----- Prefix variables for Homebrew -----
prefix ?= /usr/local
bindir ?= $(prefix)/bin)

# Derive sources (optional; triggers rebuilds if any Swift file changes)
srcdir := Sources
SOURCES := $(shell find $(srcdir) -type f -name '*.swift' 2>/dev/null)

.DEFAULT_GOAL := all

.PHONY: all
all: build

# Build the Swift package (binary ends up in the SwiftPM bin path)
.PHONY: build
build: $(SOURCES)
	@swift build \
		-c $(CONFIG) \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

# Compute SwiftPM bin path for this configuration
BINPATH = $(shell swift build -c $(CONFIG) --disable-sandbox --build-path "$(BUILDDIR)" --show-bin-path)

# Install just the product binary into $(bindir)
.PHONY: install
install: build
	@install -d "$(bindir)"
	@install "$(BINPATH)/$(PRODUCT)" "$(bindir)/$(PRODUCT)"

.PHONY: uninstall
uninstall:
	@rm -f "$(bindir)/$(PRODUCT)"

.PHONY: clean
clean:
	@rm -rf "$(BUILDDIR)"

.PHONY: distclean
distclean: clean
