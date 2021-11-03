# start from base
FROM python:3.8.10
LABEL maintainer="HADI ALNEHLAWI nhadi82@hotmail.com"
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN python --version
RUN pip install -r requirements.txt
COPY . /app
ENV DB_URI="postgresql://postgres:postgres@localhost/postgres"
EXPOSE 5000
CMD ["sh", "./entrypoint.sh" ]