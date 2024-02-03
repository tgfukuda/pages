.PHONY: init
init:
	git submodule update --init --recursive
	cd themes/hugo-theme-luna && yarn install --production
	npm install
	
.PHONY: server
server:
	@ if [ -z $(env) ]; then echo "set env variable. valid options are" && ls config | grep -v _default && exit 1; fi
	hugo server -D --environment $(env)
	