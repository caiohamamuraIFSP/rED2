preprocess:
	autoreconf
	cp configure configure.ucrt

clean: 
	./cleanup

.PHONY: preprocess clean