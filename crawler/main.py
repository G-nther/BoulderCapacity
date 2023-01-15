import os
from datetime import datetime
import json
import requests
from requests.adapters import HTTPAdapter, Retry
import functions_framework
from google.cloud import storage

def get_data(url: str) -> str:

    s = requests.Session()

    retries = Retry(total=10,
                    backoff_factor=2,
                    status_forcelist=[ 500, 502, 503, 504 ])

    s.mount('http://', HTTPAdapter(max_retries=retries))
    s.mount('https://', HTTPAdapter(max_retries=retries))

    response = s.get(url)

    if response.status_code != 200:
        raise Exception(f"status code 200 was expected but got {response.status_code}.")

    return response.text


def load_to_gcs(data: str, bucket: str, blobname: str, format: str):

    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket)
    blob = bucket.blob(f"{blobname}.{format.lower()}")
    blob.upload_from_string(data)
    
def get_data_format(data: str) -> str:

    try:
        d = json.loads(data)
        return "JSON"
    except json.decoder.JSONDecodeError:
        if "<!DOCTYPE HTML" in data.upper():
            return "HTML"
        else:
            return "UNKNOWN"

@functions_framework.http
def main(request):
    currentDateAndTime = datetime.now()
    url = os.environ.get("CRAWLER_URL")
    bucket = os.environ.get("CRAWLER_BUCKET")
    blobname = f"{os.environ.get('K_SERVICE')}/{currentDateAndTime.strftime('%Y-%d-%m_%H-%M-%S')}"
    data = get_data(url)
    format = get_data_format(data)
    load_to_gcs(data, bucket, blobname, format)