.PHONY: generate lint format format-check test build archive clean

generate:
	xcodegen generate

lint:
	swiftlint lint --strict

format:
	swiftformat . --config .swiftformat

format-check:
	swiftformat . --config .swiftformat --lint

test:
	xcodebuild test \
		-scheme MBC \
		-destination "platform=iOS Simulator,name=iPhone 16 Pro" \
		-resultBundlePath ./build/test-results.xcresult \
		CODE_SIGNING_ALLOWED=NO | xcpretty

build:
	xcodebuild build \
		-scheme MBC \
		-destination "platform=iOS Simulator,name=iPhone 16 Pro" \
		CODE_SIGNING_ALLOWED=NO | xcpretty

archive:
	bundle exec fastlane archive

clean:
	rm -rf build/ DerivedData/
	xcodebuild clean -scheme MBC 2>/dev/null || true
