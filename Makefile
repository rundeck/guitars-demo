# makefile
PLUGINS = mtl-exec-plugin git-nodes-plugin

.PHONY: plugins $(PLUGINS)


plugins: $(PLUGINS)

$(PLUGINS): mtl
	$(MAKE) -C plugins/$@

