# DevOpsEngineneer

Написать Jenkins pipeline, который разворачивает инстансы в YANDEX, производит на них сборку Java приложения и деплоит приложение на стэйдж. Необходимо использовать код Terraform и Ansible. Приложение должно быть развернуто в контейнере.

### Сервер "MASTER" (Jenkins+Terraform+Ansible) создаёт две VM (assembly & prod), управляет ими
  - #### Подготовка YANDEX-облака:
    - #### convert my OAuth-token to IAM-token
    - sudo curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
    - yc init
    - yc config list
  - #### Подготовка инфраструктуры:
    - sudo apt update
    - sudo apt-get update
    - sudo apt-get install mc -y
    - sudo apt install git -y
    - sudo apt install unzip -y
    - #### установка Jenkins
    - https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
    - sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    - echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    - sudo apt-get install jenkins -y
    - sudo apt install fontconfig openjdk-17-jre -y
    - sudo systemctl start jenkins
    - sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    - #### установка Terraform
    - cd /tmp
    - git clone https://github.com/spring108/terraform.git
    - cd /tmp/terraform
    - unzip terraform_1.7.0_linux_amd64.zip
    - mv /tmp/terraform/terraform /bin
    - chmod +x /bin/terraform
    - sudo nano ~/.terraformrc #подключить зеркало яндекс
    - sudo /var/lib/jenkins/.terraformrc #подключить зеркало яндекс
    - #### установка Ansible
    - sudo apt update
    - sudo apt policy ansible #ansible 2.5.1
    - sudo apt install -y software-properties-common
    - sudo add-apt-repository --yes --update ppa:ansible/ansible
    - sudo apt update
    - sudo apt policy ansible #ansible 2.9.27
    - sudo apt install ansible -y
    - ansible --version #ansible 2.9.27
    - /etc/ansible/hosts <<<<<<<<<<<<<<<<<<<<<<<<<<<
  - #### Настройка Jenkins:
    - создание задания DevOpsEngineneer
      - параметризованная сборка (String Parameter: имя = version ; значение по умолчанию = v2.0.0)
      - Pipeline
        - Repository URL = https://github.com/spring108/DevOpsEngineneer.git
        - Branch Specifier = */main
        - Script Path = jenkins/pipeline.jenkins
## Сервер assembly:
  - его создаёт и управляет сервер "MASTER"
## Сервер prod:
  - его создаёт и управляет сервер "MASTER"
## Смотрим http://prod_ip:8080/hello