#spore makerlabs soundscape version 1 by marc December 2018

########### LOAD LIBRARIES AND SAMPLES #####################
dir = " " #your path here
load_sample dir

################### DEFINE GLOBALS ##########################
use_osc "localhost", 12000
use_random_seed 4

#################### UTILITY FUNCTIONS ##########################

define :listOnsets do |s|
  onsetsMaps = [] #initialise a blank list
  l = lambda {|c| onsetsMaps = c.to_a; c[0]} #set the info obtained in :listonsets
  sample s, onset: l,amp: 0,finish: 0 #trigger the lambda function played sample at 0 volume and finish=0
  #listOnsets returns a normalized list of start finish times for transients in a given sample
  return onsetsMaps.ring
end

define :transientSend do |name|
  s = dir, name
  #for some reason the first time you run this on a sample it returns a list with nothing in it...magic
  onsets = listOnsets(s)
  transients = []
  onsets.each_with_index do |(key,value), index|
    #at some point find a cleaner way to index a list starting at the second value all the way to the end
    transient_diff = onsets[index+1][:start] - onsets[index][:start] #calculates the normalized difference between start times
    transients << ((transient_diff * sample_duration(s)) * 1000 * 0.06).to_i #appends converted values -> normalized diff -> millisecond -> framerate (60fps) conversion
  end

  transients.pop

  return transients.join(" ")
end

define :sender do |bird, i_range, a_max = 1|
  #generates random amp and pan values then sends them and the transient values over osc
  send_amp = quantise(rrand(0.01, a_max), 0.1)
  send_pan = quantise(rrand(-1, 1), 0.1)
  name = bird + rrand(i_range[0], i_range[1]).to_i.to_s
  send_trans = transientSend(name)
  osc "/bird/", send_amp, send_pan, send_trans
  sample dir, name, amp: send_amp, pan: send_pan
end

############ CIRCADIAN RHYTHM ###############
live_loop :circadian do
  #general bird activity ebbs and flows at an hourly rate
  set :chorus_mul, -10*Math.cos(((Math::PI * 2.0)/3600) * tick) + 13
  t = Time.now
  #at night the birds fall silent
  t.hour >= 18 || t.hour < 6 ? (set :mode, "night"; cue :frogs; osc "/frogs/") : (set :mode, "day"; cue :birds)
  wait 1
end

############ BIRD SOUNDS ##################
with_fx :reverb, room: 0.9 do
  live_loop :bee do
    sync :birds
    sender "bee", [1, 15] #replace names with your sample bank names
    wait rrand(1, 7) + get[:chorus_mul]
  end

  live_loop :chopcheep do
    sync :birds
    sender ["chop", "cheep"].choose, [1, 3]
    wait rrand(10, 20) + get[:chorus_mul]
  end
end

with_fx :reverb, room: 0.6 do
  live_loop :lark do
    sync :birds
    sender "lark", [1, 5]
    wait rrand(9, 12) + get[:chorus_mul]
  end

  live_loop :warbler do
    sync :birds
    sender "warbler", [1, 5]
    wait rrand(3, 9) + get[:chorus_mul]
  end

  live_loop :twiddle do
    sync :birds
    sender "twiddle", [1, 4], 0.2
    wait rrand(10, 20) + get[:chorus_mul]
  end
end

########### AMBIENCE ################
live_loop :crickets do
  l = dir, "crickets_" + get[:mode]
  sample l, amp: 2
  wait (sample_duration l) - 2
end

live_loop :frogs do
  sync :frogs
  l = dir, "frogs_night"
  sample l, amp: 2
  wait (sample_duration l) - 4
end

live_loop :frog do
  sync :frogs
  l = dir, "frog"
  sample l, amp: 5, pan: rrand(-1, 1)
  wait (sample_duration l) - 4
end

live_loop :forest do
  sync :birds
  l = dir, "forest_day"
  sample l, amp: 2
  wait (sample_duration l) - 2
end
