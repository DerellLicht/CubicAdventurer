//******************************************************************************
//  ccTimers
//
//  revival: replaces the small part of the Fundamentals library unit cTimers
//  that CubicExplorer used (StartTimer and friends). Fundamentals is not part
//  of CubicAdventurer. The timer value is a high resolution counter taken from
//  the WinAPI QueryPerformanceCounter, as in the original.
//
//  Released under CC0.
//******************************************************************************
unit ccTimers;

interface

// Gets the current value of the high resolution counter.
procedure StartTimer(out ATimer: Int64);

// Milliseconds elapsed since ATimer was started.
function MillisecondsElapsed(const ATimer: Int64): Int64;

implementation

uses
  Windows;

var
  fFrequency: Int64 = 0;

procedure StartTimer(out ATimer: Int64);
begin
  if not QueryPerformanceCounter(ATimer) then begin
    // no high resolution counter, fall back to milliseconds
    ATimer:= GetTickCount64;
  end;
end;

function MillisecondsElapsed(const ATimer: Int64): Int64;
var
  now: Int64;
begin
  if fFrequency = 0 then begin
    if not QueryPerformanceFrequency(fFrequency) then begin
      fFrequency:= -1;
    end;
  end;
  if fFrequency > 0 then begin
    QueryPerformanceCounter(now);
    Result:= ((now - ATimer) * 1000) div fFrequency;
  end else begin
    Result:= GetTickCount64 - ATimer;
  end;
end;

end.
