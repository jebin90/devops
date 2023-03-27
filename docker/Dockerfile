FROM python:3.9-alpine

ADD main.py .
RUN apk add --no-cache g++ nginx
RUN pip install numpy
COPY main.py /app/
COPY output.txt /app/output.txt
COPY nginx.conf /etc/nginx/nginx.conf
CMD sh -c "python ./main.py &" && nginx -g 'daemon off;'
