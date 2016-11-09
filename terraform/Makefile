graph:
	terraform graph | dot -Tpng > graph.png

ssh-key:
	mkdir ssh; ssh-keygen -t rsa -C "jenkins" -P '' -f ssh/jenkins

plan:
	terraform get -update=true
	terraform plan -refresh=true -input=false

apply:
	terraform get -update=true
	terraform apply -refresh=true -input=false
