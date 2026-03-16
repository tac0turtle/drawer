.PHONY: generate build test lint clean

generate:
	xcodegen generate

build: generate
	xcodebuild -scheme Drawer -configuration Debug build

release: generate
	xcodebuild -scheme Drawer -configuration Release build

test: generate
	xcodebuild -scheme Drawer test

lint:
	swiftlint --strict

clean:
	rm -rf build DerivedData
