build:
	docker build -t web .

run:
	docker run --name webcont -p 5000:5000 -d web

down:
	docker stop webcont && docker rm webcont

up: build run