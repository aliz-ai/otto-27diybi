from google.cloud import storage

def bucket_fits_schema(bucket):
    if len(bucket.split('-')) == 3:
        return bucket.split('-')[-1] in ['personal', 'team']
    
def blob_allowed_to_stay(blob):
    return blob.split('.')[-1] not in ['csv']

gcs_client = storage.client.Client('aliz-diybi-ia')
all_buckets = gcs_client.list_buckets()
all_relevant_buckets = [bucket for bucket in all_buckets if bucket_fits_schema(bucket.name)]
for bucket in all_relevant_buckets:
    bucket_name_array = bucket.name.split('-')
    team_name = bucket_name_array[0]
    personal = (bucket_name_array[-1] == 'personal')
    if personal:
        all_blobs = gcs_client.list_blobs(bucket)
        all_relevant_blobs = [blob for blob in all_blobs if blob_allowed_to_stay(blob.name)]
        destination_bucket = gcs_client.bucket(f"{team_name}-common-team")
        for blob in all_relevant_blobs:
            bucket.copy_blob(blob, destination_bucket, blob.name)