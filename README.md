# RobustQ

a web service to quantify cellular robustness

## Requirements

To run the development server locally, you will need
* Python 3.6 or higher
* Django 2.x or higher
* Celery 4.4
* python-libsbml
* mysqlclient
* a MySQL/MariaDB database

You may also run `pip install requirements_pip.txt` to install any further missing dependencies. 

In order to run celery you will need a message broker. I use RabbitMQ, [other services such as Redis are supported however](https://docs.celeryproject.org/en/latest/getting-started/brokers/)

The binaries and scripts for the computational pipeline are provided. You may need to install certain perl modules.

After successful setup make sure to run your migrations and start up your celery worker. By default, I use two workers with `--concurrency=1`. You may set these up in whatever way you like though, and performance may be improved by increasing concurrency setting. Keep in mind however, certain tasks (such as the MCS count) take a lot of resources and should not be run in parallel.

## Usage

After account creation, You will need a valid SBML model. Supported filetypes are .xml, .json, or (in future versions) .zip. Simply upload your model, tweak the parameters to your liking and hit submit. This will queue the job and execute it accordingly (reminder: make sure you have your celery workers running. If you are unsure, head to the [official docs](https://docs.celeryproject.org/en/latest/getting-started/)).

![Landing page](https://raw.githubusercontent.com/domvie/RobustQ/master/static/img/index.png "Opening site")

You will be redirected to the overview site.

![Overview](https://raw.githubusercontent.com/domvie/RobustQ/tree/master/static/img/over.png "Job Overview")

And when your job is finished you can check and download the results by clicking on 'Details'.

![Details](https://raw.githubusercontent.com/domvie/RobustQ/tree/master/static/img/results.png "Job Results")


