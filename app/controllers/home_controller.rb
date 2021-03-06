class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  def index
    # landing page for entire site.
  end

  def dashboard
    @your_notes = Note.find(:all, :order => ["created_at DESC"], :conditions => ["user_id = ?", current_user.id])
    @recent_favorites = Favorite.recent
    @recently_read = Read.order("created_at DESC").limit(10).includes(:user, :readable)
    @recent_notes = Note.order("created_at DESC").limit(10).includes(:user, :notable)
  end
end
