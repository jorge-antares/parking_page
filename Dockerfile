FROM python:3.13-alpine AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.13-alpine
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
COPY templates/ templates/

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 5000
HEALTHCHECK --interval=120s --timeout=5s --start-period=60s --retries=3 \
  CMD ["python","-c","import urllib.request,sys; r=urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=4); sys.exit(0 if r.getcode()==200 else 1)"]
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile","-","--error-logfile","-","app:app"]
