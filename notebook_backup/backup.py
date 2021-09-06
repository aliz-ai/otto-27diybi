def backup_project_notebooks(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    from google.cloud import storage

    WHITELISTED_EXTENSIONS = ['py', 'sh', 'ipynb']

    def bucket_fits_schema(bucket):
        # We are assuming buckets are either in the format of teamname-personname-personal or teamname-common-team
        if len(bucket.split('-')) >= 3:
            return bucket.split('-')[-1] in ['collaboration', 'backup']
        
    def blob_allowed_to_stay(blob):
        return blob.split('.')[-1] in WHITELISTED_EXTENSIONS

    gcs_client = storage.client.Client()
    all_buckets = gcs_client.list_buckets()
    all_relevant_buckets = [bucket for bucket in all_buckets if bucket_fits_schema(bucket.name)]

    for bucket in all_relevant_buckets:
        bucket_name_array = bucket.name.split('-')
        team_name = bucket_name_array[0]
        personal = (bucket_name_array[-1] == 'backup')

        if personal:
            all_blobs = gcs_client.list_blobs(bucket)
            all_relevant_blobs = [blob for blob in all_blobs if blob_allowed_to_stay(blob.name)]
            destination_bucket = gcs_client.bucket(f"{team_name}-ml-collaboration")

            for blob in all_relevant_blobs:
                bucket.copy_blob(blob, destination_bucket, f"{bucket.name}/{blob.name}")
