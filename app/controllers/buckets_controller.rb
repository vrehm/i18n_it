class BucketsController < ApplicationController
  def new
    @project = Project.find(params[:project_id])
    @bucket = Bucket.new
    @bucket.project = @project
    authorize @bucket
  end

  def create
    @project = Project.find(params[:project_id])
    @bucket = Bucket.new(bucket_params)
    @bucket.project = @project
    authorize @bucket
    if @bucket.save
      if @bucket.kind == "s"
        redirect_to edit_bucket_path(@bucket)
      elsif @bucket.kind == "d"
        redirect_to new_bucket_bucket_schema_path(@bucket)
      end
    else
      render :new
    end
  end

  def edit
    @bucket = Bucket.find(params[:id])
    authorize @bucket
    @translation_keys = @bucket.translations.map { |translation| translation.translation_key }.uniq
    # if bucket.kind == "d"
    @bucket_schemas = @bucket.bucket_schemas
    @sub_buckets = @bucket.sub_buckets
  end

  def update
    @bucket = Bucket.find(params[:id])
    authorize @bucket
    @sub_bucket = SubBucket.find(params[:sub_bucket_id]) if @bucket.kind == "d"
    @translation_keys = @bucket.translations.map { |translation| translation.translation_key }.uniq
    @translation_keys.each do |key|
      @bucket.project.languages.each do |language|
        if @bucket.kind == "s"
            translation = Translation.find_or_create_by(translation_key: key, language: language, bucket: @bucket) unless params[:translation_keys][:value] == ""
          unless translation.nil?
            translation.translation_key = params[:translation_keys][key][:value] unless translation.translation_key == params[:translation_keys][key][:value]
            translation.text = params[:translation_keys][key][language.language_key] unless translation.translation_key == params[:translation_keys][key][language.language_key]
          end
        elsif @bucket.kind == "d"
          camelKey = key.split("_").map { |word| word.capitalize }.join(' ')
          translation = Translation.find_or_create_by(translation_key: key, language: language, bucket: @bucket, sub_bucket: @sub_bucket)
          translation.translation_key = params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][camelKey][:value] unless translation.translation_key == params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][camelKey][:value]
          translation.text = params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][camelKey][language.language_key] unless translation.translation_key == params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][camelKey][language.language_key]
          translation.sub_bucket = @sub_bucket
        end
        unless translation.nil?
          translation.bucket = @bucket
          translation.language = language
          translation.save
        end
      end
      anchor = nil
    end
    if @bucket.kind == "s"
      unless params[:translation_keys][:new_translation_key][:value] == ""
        @bucket.project.languages.each do |language|
          Translation.create(language: language, bucket: @bucket, translation_key: params[:translation_keys][:new_translation_key][:value], text: params[:translation_keys][:new_translation_key][language.language_key]) unless params[:translation_keys][:new_translation_key][language.language_key] == ""
        end
      end
    elsif @bucket.kind == "d"
      @bucket.bucket_schemas.each do |bucket_schema|
        @bucket.project.languages.each do |language|
          unless Translation.find_by(language: language, bucket: @bucket, sub_bucket: @sub_bucket, translation_key: params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][bucket_schema.bucket_schema_name][:value], text: params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][bucket_schema.bucket_schema_name][language.language_key])
            Translation.create(language: language, bucket: @bucket, sub_bucket: @sub_bucket, translation_key: params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][bucket_schema.bucket_schema_name][:value], text: params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][bucket_schema.bucket_schema_name][language.language_key]) unless params[:translation_keys]['sub_bucket_' + @sub_bucket.id.to_s][bucket_schema.bucket_schema_name][language.language_key] == ""
          end
        end
      end
      anchor = @sub_bucket.id
    end
    redirect_to edit_bucket_path(@bucket, anchor: anchor)
  end

  private

  def bucket_params
    params.require(:bucket).permit(:bucket_name, :kind)
  end
end
