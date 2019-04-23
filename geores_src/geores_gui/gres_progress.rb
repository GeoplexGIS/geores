Sketchup::require 'geores_src/geores_gui/time.rb'

class GRES_Progress

@@err_total_notnumeric = "ProgressBar: Total must be a positive integer."
@@err_count_notnumeric = "ProgressBar: Iteration Count must be numeric"
@@end_time             = "Expected End Time:"
@@progresschar = ">"
@@initial_block = "-" * 50     # Default progress bar line sequence.
@iteration = 0

def initialize(total,phase=nil)
  if (!total.integer? or total < 0)
    raise(ArgumentError,@@err_total_notnumeric)
    return
  end
 @id = UI.start_timer(1, false) { update(@iteration) }
  @total = total.to_i
  @phase = phase
  @firsttime = true
end

def setphase (ph)
  @phase = ph
end

def update(iteration)
  @iteration = iteration
  if(@iteration == nil)
    return
  end
  if !iteration.integer?
    raise(ArgumentError,@@err_count_notnumeric)
    return
  end
  @iteration = [@iteration.abs,@total].min  # make sure we don't exceed the total count or have a value < 0
  pct = [1,(@iteration*100)/@total].max    # Calculate percentage complete.
                                          # round up to 1% if anything less than 1%.
  end_time = "?"
  if (@firsttime == true)
    # Get the current time of day.
    # set up an elapsed timer so we can calculate expected end time.
    @time1 = Time.now     # Get current time of day.
    @firsttime = false    # turn off switch
  else
    # divide the elapsed time by the pct complete, then multiple that by 100, then add that to the
    # start time, and that is the expected end time.
    end_time = Time.at(((((Time.now-@time1).to_f)/pct)*100 + @time1.to_f).to_i).strftime("%c")
 end
  pct_pos = [pct/2,1].max
  current_block = @@initial_block[0,pct_pos-1] << @@progresschar << @@initial_block[pct_pos,@@initial_block.length]
  Sketchup.set_status_text(current_block + "   "  + pct.to_s + "%. #{@@end_time} " + end_time + "<< #{@phase}")
end

def end_timer
    if(@id)
      UI.stop_timer @id
    end
end
end


