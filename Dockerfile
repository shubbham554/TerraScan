FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /srv
COPY TerraScan_Release.zip /tmp/terrascan.zip
RUN python -m zipfile -e /tmp/terrascan.zip /srv && rm /tmp/terrascan.zip
WORKDIR /srv/TerraScan
RUN mkdir -p data && python -c "from urllib.request import urlretrieve; from zipfile import ZipFile; p='data/ne_10m_land.zip'; urlretrieve('https://naturalearth.s3.amazonaws.com/10m_physical/ne_10m_land.zip', p); assert 'ne_10m_land.shp' in ZipFile(p).namelist()"
RUN pip install --no-cache-dir -r requirements.txt -r requirements-runtime.txt \
    && useradd --system --uid 10001 --no-create-home terrascan
USER 10001
EXPOSE 10000
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-10000}"]
