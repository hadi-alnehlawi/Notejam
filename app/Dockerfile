# start from base
FROM python:3.8.10
LABEL maintainer="HADI ALNEHLAWI nhadi82@hotmail.com"
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN python --version
RUN pip install -r requirements.txt
COPY . /app
RUN pip install Flask gunicorn
ENV DB_USER="postgres"
ENV DB_PASS="postgres"
ENV DB_NAME="postgres"
ENV DB_PORT="5432"
ENV DB_HOST="localhost"
# Install production dependencies.
# RUN pip install Flask gunicorn
EXPOSE 5000
CMD ["sh", "./entrypoint.sh" ]