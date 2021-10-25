# start from base
2
FROM ubuntu:18.04
3
4
LABEL maintainer="Your Name <youremailaddress@provider.com>"
5
6
RUN apt-get update -y && \
7
    apt-get install -y python-pip python-dev
8
9
10
# We copy just the requirements.txt first to leverage Docker cache
11
COPY ./requirements.txt /app/requirements.txt
12
13
WORKDIR /app
14
15
RUN pip install -r requirements.txt
16
17
COPY . /app
18
19
CMD [ "python", "./app.py" ]