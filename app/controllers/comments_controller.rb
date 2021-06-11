class CommentsController < ApplicationController
  before_action :check_for_video

  def index
    builder = IndexBuilder::Comments.new(params).perform
    return render_bad_request(builder.errors) if builder.errors.any?

    @comments = builder.comments
    render_bad_request(['Page must lower than maximum']) if @comments.out_of_range? && builder.page > 1
  end

  def create
    @comment = Comment.new(**create_params, user: @current_user)
    if @comment.save
      render template: 'comments/create', status: :created
    else
      render_bad_request(@comment.errors.full_messages)
    end
  end

  private

  def create_params
    params.permit(:video_id, :body)
  end

  def check_for_video
    Video.find(params[:video_id])
  end
end
