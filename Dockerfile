FROM python:3.7-alpine
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev linux-headers
RUN adduser -D app
USER app
WORKDIR /usr/local/src
COPY requirements.txt .
ENV PATH "$PATH:/home/app/.local/bin"
RUN pip install -r requirements.txt --user
COPY . .
CMD ["uwsgi", "--ini", "uwsgi.ini"]
