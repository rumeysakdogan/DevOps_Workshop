FROM python:alpine
RUN pip install flask
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python ./welcome.py