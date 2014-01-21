
all: clean zip

clean:
	rm -rf dist
	mkdir dist
zip: 
	mkdir -p dist/git-nodes-plugin
	cp -r src/* dist/git-nodes-plugin
	(cd dist; zip -r ../dist/git-nodes-plugin.zip git-nodes-plugin)

install: zip
	cp dist/git-nodes-plugin.zip $(RDECK_BASE)/libext
