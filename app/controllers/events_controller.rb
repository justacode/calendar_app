class EventsController < ApplicationController

  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @date = params[:date] ? params[:date].to_date: Date.current
    @events = set_events

    unless params[:tag] || params[:all] || params[:search]
      @calendar = CalendarService.new(@date).create_calendar
      @events = day_events
    end
  end

  def show
  end

  def new
    @event = current_user.events.build
  end

  def edit
  end

  def create
    @event = current_user.events.new(event_params)
    @event.start_date = set_date_with_time
    @event.finish_date = set_finish_date

    if @event.save
      redirect_to events_path, notice: "Event successfully created"
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        redirect_to @event, notice: 'Event was successfully updated.'
      else
        render :edit
      end
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_events
    if params[:all]
      current_user.events
    elsif params[:tag]
      Event.by_tag_name(params[:tag])
    elsif params[:search]
      SearchService.new.fetch_events(params[:search])
    end
  end

  def set_date_with_time
    time = params[:time].to_s.split(":")
    @event.start_date.change(hour: time.first, min: time.last)
  end

  def set_finish_date
    if @event.frequency == "once"
      @event.start_date
    elsif params[:forever]
      nil
    else
      @event.finish_date
    end
  end

  def day_events
    date = params[:day] ? params[:day].to_date : @date
    @calendar[date] unless @date == params[:date]
  end

  def event_params
    params.require(:event).permit(:name, :description, :frequency, :user_id, :start_date, :finish_date, :tags)
  end
end
