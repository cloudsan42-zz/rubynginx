image:
	docker build -t test_web_app .

server:
	docker run -p 443:443 -it test_web_app 
