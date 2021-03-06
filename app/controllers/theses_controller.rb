class ThesesController < ApplicationController
  before_filter :authenticate_user!#, :except => [:index, :show]
  caches_action :index
  caches_action :show
  cache_sweeper :thesis_sweeper

  # GET /theses
  # GET /theses.json
  def index
    @theses = Thesis.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @theses }
    end
  end

  # GET /theses/1
  # GET /theses/1.json
  def show
    @thesis = Thesis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thesis }
    end
  end

  # GET /theses/new
  # GET /theses/new.json
  def new
    @thesis = Thesis.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @thesis }
    end
  end

  # GET /theses/1/edit
  def edit
    @thesis = Thesis.find(params[:id])
  end

  # POST /theses
  # POST /theses.json
  def create
    # Create a new thesis
    @thesis = Thesis.new(params[:thesis])
    
    # Attach the person, we can create a new Person
    # because you only graduate from ITP once and so only
    # have one thesis. Any identical names should be assumed
    # to be different people.
    @thesis.person = Person.new(params[:person])

    # raise params[:new_documentation][:media].tempfile.inspect

    if params[:new_documentation]
      documentation = Article.new({
        title: params[:new_documentation][:title],
        paper: params[:new_documentation][:paper],
        has_images: params[:new_documentation][:has_images],
        flag: params[:new_documentation][:flag],
        integrity: params[:new_documentation][:integrity],
        media: params[:new_documentation][:media]
      })
      documentation.notes << Note.new(body: params[:new_documentation][:notes], user_id: current_user.id) if params[:new_documentation][:notes].length > 0
      @thesis.documentations << documentation
    end

    respond_to do |format|
      if @thesis.save
        format.html { redirect_to @thesis, notice: 'Thesis was successfully created.' }
        format.json { render json: @thesis, status: :created, location: @thesis }
      else
        format.html { render action: "new" }
        format.json { render json: @thesis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /theses/1
  # PUT /theses/1.json
  def update
    @thesis = Thesis.find(params[:id])

    # raise ENV['S3_ACCESS_KEY'].inspect

    @thesis.documentations.each do |documentation|
      documentation.update_attributes params[:documentations][documentation.id.to_s]
    end

    if params[:new_documentation]
      documentation = Article.new({
        title: params[:new_documentation][:title],
        paper: params[:new_documentation][:paper],
        has_images: params[:new_documentation][:has_images],
        flag: params[:new_documentation][:flag],
        integrity: params[:new_documentation][:integrity],
        media: params[:new_documentation][:media]
      })
      documentation.notes << Note.new(body: params[:new_documentation][:notes], user_id: current_user.id) if params[:new_documentation][:notes].length > 0
      @thesis.documentations << documentation
    end

    @thesis.person.update_attributes(params[:person])

    respond_to do |format|
      if @thesis.update_attributes(params[:thesis])
        format.html { redirect_to @thesis, notice: 'Thesis was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @thesis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /theses/1
  # DELETE /theses/1.json
  def destroy
    @thesis = Thesis.find(params[:id])
    @thesis.destroy

    respond_to do |format|
      format.html { redirect_to theses_url }
      format.json { head :ok }
    end
  end
end