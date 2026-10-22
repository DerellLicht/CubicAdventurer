unit CE_FontFallback;

// Glyph fallback for file names: when the font in use lacks glyphs for some
// characters of a text, pick an installed font that has them.
// (GDI DrawTextW does no automatic font fallback for many fonts.)

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Generics.Collections;

// Returns '' if AFont already covers every character in AText (or no better
// font was found), otherwise the name of a font that covers the text best.
function CE_FindFallbackFont(AFont: TFont; const AText: string): string;

// Switches ACanvas.Font to a fallback font if the current one lacks glyphs.
procedure CE_ApplyFontFallback(ACanvas: TCanvas; const AText: string);

var
  CEFontFallbackEnabled: Boolean = true;

implementation

const
  Candidates: array[0..11] of string = (
    'Segoe UI', 'Segoe UI Symbol', 'Arial Unicode MS', 'Microsoft YaHei UI',
    'Meiryo UI', 'Malgun Gothic', 'Microsoft JhengHei UI', 'Nirmala UI',
    'Segoe UI Emoji', 'Cambria Math', 'MS Gothic', 'Arial');

var
  MemDC: HDC = 0;
  Cache: TDictionary<string, string> = nil;

function FontInstalled(const AName: string): Boolean;
begin
  Result:= Screen.Fonts.IndexOf(AName) >= 0;
end;

function NeedsCheck(const AText: string): Boolean;
var
  i: Integer;
begin
  Result:= false;
  for i:= 1 to Length(AText) do
    if Ord(AText[i]) > $7F then
    begin
      Result:= true;
      Exit;
    end;
end;

// number of characters of AText missing in the font selected into DC
function MissingCount(DC: HDC; const AText: string): Integer;
var
  buf: array of Word;
  i, n: Integer;
begin
  Result:= 0;
  n:= Length(AText);
  if n = 0 then Exit;
  SetLength(buf, n);
  if GetGlyphIndicesW(DC, PWideChar(AText), n, @buf[0], GGI_MARK_NONEXISTING_GLYPHS) = GDI_ERROR then
    Exit;
  for i:= 0 to n - 1 do
    if (buf[i] = $FFFF) and (AText[i + 1] > ' ') then
      Inc(Result);
end;

function MissingWithFace(const AFace: string; const ALogFont: TLogFont; const AText: string): Integer;
var
  lf: TLogFont;
  f, old: HFONT;
begin
  lf:= ALogFont;
  FillChar(lf.lfFaceName, SizeOf(lf.lfFaceName), 0);
  StrPLCopy(lf.lfFaceName, AFace, LF_FACESIZE - 1);
  lf.lfCharSet:= DEFAULT_CHARSET;
  f:= CreateFontIndirect(lf);
  old:= SelectObject(MemDC, f);
  try
    Result:= MissingCount(MemDC, AText);
  finally
    SelectObject(MemDC, old);
    DeleteObject(f);
  end;
end;

function CE_FindFallbackFont(AFont: TFont; const AText: string): string;
var
  lf: TLogFont;
  key: string;
  best, bestMissing, m, i: Integer;
begin
  Result:= '';
  if not CEFontFallbackEnabled then Exit;
  if not NeedsCheck(AText) then Exit;
  if MemDC = 0 then MemDC:= CreateCompatibleDC(0);
  if Cache = nil then Cache:= TDictionary<string, string>.Create;
  key:= AFont.Name + #1 + AText;
  if Cache.TryGetValue(key, Result) then Exit;
  if Cache.Count > 4000 then Cache.Clear;

  GetObject(AFont.Handle, SizeOf(lf), @lf);
  bestMissing:= MissingWithFace(AFont.Name, lf, AText);
  best:= -1;
  if bestMissing > 0 then
    for i:= Low(Candidates) to High(Candidates) do
    begin
      if SameText(Candidates[i], AFont.Name) then Continue;
      if not FontInstalled(Candidates[i]) then Continue;
      m:= MissingWithFace(Candidates[i], lf, AText);
      if m < bestMissing then
      begin
        bestMissing:= m;
        best:= i;
        if m = 0 then Break;
      end;
    end;
  if best >= 0 then Result:= Candidates[best];
  Cache.Add(key, Result);
end;

procedure CE_ApplyFontFallback(ACanvas: TCanvas; const AText: string);
var
  name: string;
begin
  name:= CE_FindFallbackFont(ACanvas.Font, AText);
  if name <> '' then ACanvas.Font.Name:= name;
end;

initialization

finalization
  Cache.Free;
  if MemDC <> 0 then DeleteDC(MemDC);

end.
