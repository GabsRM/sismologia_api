class Api::FeaturesController < ApplicationController
  def index
    per_page = params[:per_page].to_i.clamp(1, 1000)
    page = params[:page].to_i.clamp(1, Float::INFINITY)
    mag_types = params.dig(:filters, :mag_type)

    features = Feature.all
    features = features.where(mag_type: mag_types) if mag_types.present?

    total = features.count
    features = features.limit(per_page).offset((page - 1) * per_page)

    response = {
      data: features.map { |feature| serialize_feature(feature) },
      pagination: {
        current_page: page,
        total: total,
        per_page: per_page
      }
    }

    render json: response
  end

  def serialize_feature(feature)
    {
      id: feature.id,
      type: 'feature',
      attributes: {
        external_id: feature.external_id,
        magnitude: feature.magnitude,
        place: feature.place,
        time: feature.time.iso8601,
        tsunami: feature.tsunami,
        mag_type: feature.mag_type,
        title: feature.title,
        coordinates: {
          longitude: feature.longitude,
          latitude: feature.latitude
        }
      },
      links: {
        external_url: feature.url
      }
    }
  end
  
  def create_comments
    feature = Feature.find(params[:id])
    comment =feature.comment.build(comment_params)

    if comment.save 
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
  end
  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
end
