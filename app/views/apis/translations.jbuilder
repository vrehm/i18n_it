json.array!(@translations) do |translation|
  json.id translation.id
  json.translation_key translation.translation_key
  json.language_key translation.language.language_key
  json.text translation.text
  json.bucket_name translation.bucket.bucket_name
  json.project_name translation.bucket.project.project_name
  json.company_name translation.bucket.project.company.company_name
end