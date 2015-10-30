json.array!(@output) do |translation|
  json.ids ActiveSupport::JSON.decode(translation["ids"])
  json.translation_key translation["translation_key"]
  json.sub_bucket_name translation["sub_bucket_name"] if translation["sub_bucket_name"]
  json.bucket_id translation["bucket_id"]
  json.project_name translation["project_name"]
  json.translations ActiveSupport::JSON.decode(translation["translations"])
end