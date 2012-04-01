all: git-hooks swf/HTTPGet.swf

run: all
	( python -m SimpleHTTPServer )

lint:
	python git-tools/lint.py

git-hooks:
	python git-tools/setupGitHooks.py

clean:
	rm -rf swf


swf/HTTPGet.swf: src/HTTPGet.as
	mxmlc -benchmark=True -creator=jfly -static-link-runtime-shared-libraries=true -output=$@ $^
