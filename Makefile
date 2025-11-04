build:
	podman build \
	  --build-arg UID=$(shell id -u) \
	  --build-arg GID=$(shell id -g) \
	  --no-cache \
	  -t docker-ide .
run:
	podman run -it --rm \
	    --privileged \
	    --userns=keep-id \
	    --pid=host \
	    --ipc=host \
	    --network=host \
	    -v /home/me/Projects:/home/me/Projects:z \
	    -v /home/me/.ssh:/home/me/.ssh:z \
	    -v /home/me/.gitconfig:/home/me/.gitconfig:z \
		docker-ide
