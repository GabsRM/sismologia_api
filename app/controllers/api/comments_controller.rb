class Api::CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  def create
    feature = Feature.find(params[:feature_id])
    comment = feature.comments.build(comment_params)

    if comment.save
      render json: { message: 'Comment created successfully' }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Feature not found' }, status: :not_found
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
