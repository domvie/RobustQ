FROM ubuntu
ENV TZ=Europe/Vienna
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-utils vim curl apache2 apache2-utils mariadb-server libmariadbclient-dev git
RUN apt-get -y install python3-dev libapache2-mod-wsgi-py3 rabbitmq-server python3-pip python3-virtualenv
RUN python3 -m virtualenv --python=/usr/bin/python3 /home/Projects/RobustQ/venv
RUN pip3 install --upgrade pip
COPY requirements.txt .
RUN . /home/Projects/RobustQ/venv/bin/activate && pip3 install -r requirements.txt 
ADD ./celery_init/000-default.conf /etc/apache2/sites-available/000-default.conf
EXPOSE 80 3500
CMD ["apache2ctl", "-D", "FOREGROUND"]
