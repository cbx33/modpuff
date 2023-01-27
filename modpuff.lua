a = reaper.MIDIEditor_GetActive()
aa = reaper.MIDIEditor_GetTake(a)
aa1, aa2, aa3, aa4, aa5, aa6, aa7, aa8, aa9, aa10 = reaper.MIDI_GetCC(aa,0)
bb1, bb2 ,bb3 = reaper.MIDI_GetCCShape(aa, 0)

cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8, cc9, cc10 = reaper.MIDI_GetNote(aa, 0)

puff = {[0]=0,[100]=20,[400]=10,[500]=0}

ok, vals_csv = reaper.GetUserInputs("Set params", 2, "Amplitude,Width", "1.0,1.0")
height, width = vals_csv:match("([^,]+),([^,]+)")
 
function find_value (chan, start, cc)
  ret = true
  c = 0
  while ret ~= false do
    ret, cc2, cc3, tim, chanmsg, onchan, msg2, msg3 = reaper.MIDI_GetCC(aa, c)
    if (tim >= start) and (chan == onchan) and (cc == msg2) then
      return c
    end
    c = c + 1
  end 
  return -1
end

sel_note = {}
note = -2
while note ~= -1 do
  note = reaper.MIDI_EnumSelNotes(aa, note)
  if note ~= -1 then
    table.insert(sel_note, note)
  end
end

for i=1, #sel_note do
  note = sel_note[i]
  aa1, aa2, aa3, aa4, aa5, aa6, aa7, aa8 = reaper.MIDI_GetNote(aa, note)
  idx = find_value(aa6, aa4, 21)
  cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8 = reaper.MIDI_GetCC(aa, idx)
  for off, amp in pairs(puff) do
    tim = off * width
    mod = amp * height
    actual_height =  cc8 + mod
    if (actual_height > 127) then
      actual_height = 127
    end
    reaper.MIDI_InsertCC(aa, true, false, cc4 + tim, 176, cc6, 1, actual_height)
    bidx = reaper.MIDI_EnumSelCC(aa, -1)
    reaper.MIDI_SetCCShape(aa, bidx, 2, 0)
    reaper.MIDI_SelectAll(aa, false)
  end
  
  idx = find_value(aa6, aa5, 21)
  cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8 = reaper.MIDI_GetCC(aa, idx)
  reaper.MIDI_InsertCC(aa, true, false, aa5, 176, cc6, 1, cc8)
  bidx = reaper.MIDI_EnumSelCC(aa, 0)
  reaper.MIDI_SetCCShape(aa, bidx, 2, 0)
  reaper.MIDI_SelectAll(aa, false)
end
