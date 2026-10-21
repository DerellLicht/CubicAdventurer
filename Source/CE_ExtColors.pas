//******************************************************************************
//  CubicAdventurer
//
//  Extension color rules for the file list ("Use extension colors").
//
//  Written for the CubicAdventurer revival (2026) by Derell Licht, released CC0.
//  The behaviour follows the original CubicExplorer options page
//  (Fileview > Colors tab); the original source for it is not available.
//******************************************************************************

unit CE_ExtColors;

interface

uses
  Classes, SysUtils, Graphics, Generics.Collections;

type
  TCEExtColorRule = record
    Extensions: string;   // comma separated, lower case, no dots: 'txt,pdf,doc'
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    Color: TColor;        // clDefault = keep the normal text color
  end;

  TCEExtColorRules = class
  private
    fRules: TList<TCEExtColorRule>;
    fLookup: TDictionary<string, Integer>;
    function GetCount: Integer;
    function GetItems(Index: Integer): TCEExtColorRule;
    procedure RebuildLookup;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const Rule: TCEExtColorRule): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure LoadDefaults;
    function Find(const Ext: string; out Rule: TCEExtColorRule): Boolean;
    procedure Update(Index: Integer; const Rule: TCEExtColorRule);
    function Serialize: string;
    procedure Deserialize(const S: string);
    class function NormalizeExtensions(const S: string): string;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCEExtColorRule read GetItems; default;
  end;

implementation

const
  RULE_SEP = ';';
  FIELD_SEP = '|';

{*------------------------------------------------------------------------------
  Create an instance of TCEExtColorRules
-------------------------------------------------------------------------------}
constructor TCEExtColorRules.Create;
begin
  inherited;
  fRules:= TList<TCEExtColorRule>.Create;
  fLookup:= TDictionary<string, Integer>.Create;
end;

{*------------------------------------------------------------------------------
  Destroy an instance of TCEExtColorRules
-------------------------------------------------------------------------------}
destructor TCEExtColorRules.Destroy;
begin
  fLookup.Free;
  fRules.Free;
  inherited;
end;

function TCEExtColorRules.Add(const Rule: TCEExtColorRule): Integer;
var
  r: TCEExtColorRule;
begin
  r:= Rule;
  r.Extensions:= NormalizeExtensions(r.Extensions);
  Result:= fRules.Add(r);
  RebuildLookup;
end;

procedure TCEExtColorRules.Clear;
begin
  fRules.Clear;
  RebuildLookup;
end;

procedure TCEExtColorRules.Delete(Index: Integer);
begin
  fRules.Delete(Index);
  RebuildLookup;
end;

{*------------------------------------------------------------------------------
  Default rules: the extension groups of the original CubicExplorer.
  No colors are set, so nothing changes until the user picks colors/styles.
-------------------------------------------------------------------------------}
procedure TCEExtColorRules.LoadDefaults;
  procedure AddGroup(const Exts: string);
  var
    r: TCEExtColorRule;
  begin
    r.Extensions:= Exts;
    r.Bold:= false;
    r.Italic:= false;
    r.Underline:= false;
    r.Color:= clDefault;
    Add(r);
  end;
begin
  Clear;
  AddGroup('txt,pdf,doc,htm,html,epub,mobi,odt,rtf');
  AddGroup('c,h,cpp,hpp,rc,cfg,awk,py,cs,pas,dfm,dpr');
  AddGroup('jpg,jpeg,bmp,gif,ico,ani,cur,png,tif,tiff');
  AddGroup('exe,com,bat,btm,dll,sys,msi,jar');
  AddGroup('zip,gz,tgz,7z,rar');
  AddGroup('mp3,mp4,avi,mov,mkv');
end;

{*------------------------------------------------------------------------------
  Look up the rule for an extension (with or without leading dot, any case).
  The first rule in list order that contains the extension wins.
-------------------------------------------------------------------------------}
function TCEExtColorRules.Find(const Ext: string; out Rule: TCEExtColorRule): Boolean;
var
  key: string;
  idx: Integer;
begin
  Result:= false;
  key:= LowerCase(Ext);
  if (key <> '') and (key[1] = '.') then begin
    // (not System.Delete: inside this class 'Delete' is the list method)
    key:= Copy(key, 2, MaxInt);
  end;
  if (key <> '') and fLookup.TryGetValue(key, idx) then begin
    Rule:= fRules[idx];
    Result:= true;
  end;
end;

function TCEExtColorRules.GetCount: Integer;
begin
  Result:= fRules.Count;
end;

function TCEExtColorRules.GetItems(Index: Integer): TCEExtColorRule;
begin
  Result:= fRules[Index];
end;

{*------------------------------------------------------------------------------
  Clean up a comma separated extension list: trim, drop '*.' and '.' prefixes,
  lower case, remove empties and duplicates (order is kept).
-------------------------------------------------------------------------------}
class function TCEExtColorRules.NormalizeExtensions(const S: string): string;
var
  list: TStringList;
  parts: TArray<string>;
  p, e: string;
  i: Integer;
begin
  Result:= '';
  list:= TStringList.Create;
  try
    list.CaseSensitive:= false;
    parts:= S.Split([',', ';', ' ']);
    for i:= 0 to High(parts) do begin
      p:= Trim(parts[i]);
      if p.StartsWith('*.') then begin
        e:= Copy(p, 3, MaxInt);
      end
      else if p.StartsWith('.') then begin
        e:= Copy(p, 2, MaxInt);
      end
      else begin
        e:= p;
      end;
      e:= LowerCase(e);
      if (e <> '') and (list.IndexOf(e) < 0) then begin
        list.Add(e);
      end;
    end;
    for i:= 0 to list.Count - 1 do begin
      if i > 0 then begin
        Result:= Result + ',';
      end;
      Result:= Result + list[i];
    end;
  finally
    list.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Rebuild the extension -> rule index table (first rule wins)
-------------------------------------------------------------------------------}
procedure TCEExtColorRules.RebuildLookup;
var
  i, j: Integer;
  parts: TArray<string>;
begin
  fLookup.Clear;
  for i:= 0 to fRules.Count - 1 do begin
    parts:= fRules[i].Extensions.Split([',']);
    for j:= 0 to High(parts) do begin
      if (parts[j] <> '') and not fLookup.ContainsKey(parts[j]) then begin
        fLookup.Add(parts[j], i);
      end;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Rules <-> one string, for settings.xml:
    exts|flags|color;exts|flags|color;...
  flags is any of b, i, u. color is the TColor as a decimal integer.
-------------------------------------------------------------------------------}
function TCEExtColorRules.Serialize: string;
var
  i: Integer;
  r: TCEExtColorRule;
  flags: string;
begin
  Result:= '';
  for i:= 0 to fRules.Count - 1 do begin
    r:= fRules[i];
    flags:= '';
    if r.Bold then begin
      flags:= flags + 'b';
    end;
    if r.Italic then begin
      flags:= flags + 'i';
    end;
    if r.Underline then begin
      flags:= flags + 'u';
    end;
    if i > 0 then begin
      Result:= Result + RULE_SEP;
    end;
    Result:= Result + r.Extensions + FIELD_SEP + flags + FIELD_SEP + IntToStr(Integer(r.Color));
  end;
end;

{*------------------------------------------------------------------------------
  Parse the string produced by Serialize. Malformed entries are skipped.
-------------------------------------------------------------------------------}
procedure TCEExtColorRules.Deserialize(const S: string);
var
  entries, fields: TArray<string>;
  i: Integer;
  r: TCEExtColorRule;
begin
  fRules.Clear;
  entries:= S.Split([RULE_SEP]);
  for i:= 0 to High(entries) do begin
    fields:= entries[i].Split([FIELD_SEP]);
    if Length(fields) >= 3 then begin
      r.Extensions:= NormalizeExtensions(fields[0]);
      r.Bold:= Pos('b', fields[1]) > 0;
      r.Italic:= Pos('i', fields[1]) > 0;
      r.Underline:= Pos('u', fields[1]) > 0;
      r.Color:= TColor(StrToIntDef(fields[2], Integer(clDefault)));
      fRules.Add(r);
    end;
  end;
  RebuildLookup;
end;

procedure TCEExtColorRules.Update(Index: Integer; const Rule: TCEExtColorRule);
var
  r: TCEExtColorRule;
begin
  r:= Rule;
  r.Extensions:= NormalizeExtensions(r.Extensions);
  fRules[Index]:= r;
  RebuildLookup;
end;

end.
