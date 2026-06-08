class ArticlesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, topics: [:new, :create, :edit, :update, :destroy]
  before_action :set_article, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: [:report]

  # GET /articles or /articles.json
  def index
    public_articles = Article.where(public: true)
    if current_user.present?
      @articles = public_articles.or(Article.where(user_id: current_user.id))
    else
      @articles = public_articles
    end
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = current_user.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def report
    @article = Article.find(params[:id])
    if @article.update(reports_count: @article.reports_count + 1)
      redirect_to @article, notice: "Article has been reported."
    else
      redirect_to @article, alert: "Failed to report article."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :body, :public, :image)
    end

end
