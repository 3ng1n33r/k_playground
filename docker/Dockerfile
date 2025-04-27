FROM python:3.12-alpine

COPY requirements.txt .
RUN apk add --update --no-cache \
    openssh-client
RUN pip install --no-cache-dir --upgrade pip \ 
    && pip install --no-cache-dir -r requirements.txt

CMD [ "" ]
