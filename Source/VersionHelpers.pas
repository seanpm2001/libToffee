﻿namespace RemObjects.Elements.System;

interface

uses
  Foundation;

method CocoaVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean; inline; public;
method CocoaVersionString: String; inline; public;
method CocoaVersion: array[0..2] of Integer; inline; public;
method CocoaPlatform: String; inline; public;
method CocoaPlatformIs(s: String): Boolean; inline; public;

method __ElementsCocoaVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean; public;
method __ElementsCocoaPlatformAndVersionAtLeast(aPlatformName: String; aMaj, aMin: Integer; aRev: Integer := 0): Boolean; public;
method __ElementsCocoaVersionString: String; public;
method __ElementsCocoaUIKitForMacVersionString: String; public;
method __ElementsCocoaVersion: array[0..2] of Integer; public;
method __ElementsCocoaPlatform: String; public;
method __ElementsCocoaPlatformIs(aPlatformName: String): Boolean; public;

implementation

method CocoaVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  exit __ElementsCocoaVersionAtLeast(aMaj, aMin, aRev);
end;

method CocoaVersionString: String;
begin
  exit __ElementsCocoaVersionString;
end;

method CocoaVersion: array[0..2] of Integer;
begin
  exit __ElementsCocoaVersion;
end;

method CocoaPlatform: String;
begin
  exit __ElementsCocoaPlatform;
end;

method CocoaPlatformIs(s: String): Boolean;
begin
  exit __ElementsCocoaPlatformIs(s);
end;


var __ElementsPlatformVersion: array[0..3] of Integer;
var __ElementsUIKitForMacVersion: array[0..3] of Integer;

method __ElementsLoadCocoaVersion;
begin
  if __ElementsPlatformVersion[0] = 1 then
    exit;

  __ElementsPlatformVersion[0] := 1;
  __ElementsUIKitForMacVersion[0] := 1;
  if NSProcessInfo.processInfo.respondsToSelector(selector(operatingSystemVersion)) then begin
    {$HIDE NH0}
    var version := NSProcessInfo.processInfo.operatingSystemVersion;
    {$SHOW NH0}
    __ElementsPlatformVersion[1] := version.majorVersion;
    __ElementsPlatformVersion[2] := version.minorVersion;
    __ElementsPlatformVersion[3] := version.patchVersion;

    // hack for macOS 11.0 reporting 10.16. Hopefully we can revert before RTM
    if defined("TARGET_OS_MAC") or defined("TARGET_OS_UIKITFORMAC") then begin
      if (__ElementsPlatformVersion[1] = 10) and (__ElementsPlatformVersion[2] = 16) then begin
        __ElementsPlatformVersion[1] := 11;
        __ElementsPlatformVersion[2] := 0;
      end;
    end;

    if defined("TARGET_OS_UIKITFORMAC") and CocoaVersionAtLeast(10, 15) then begin
      if __ElementsPlatformVersion[1] = 10 then begin
        if (__ElementsPlatformVersion[2] in [15, 16]) then begin // Special handling for 10.15 and (temp) 10.16
          __ElementsUIKitForMacVersion[1] := __ElementsPlatformVersion[2]-2; // 15 -> 13, 16 -> 14
          __ElementsUIKitForMacVersion[2] := __ElementsPlatformVersion[3];
          __ElementsUIKitForMacVersion[3] := 0;
        end;
      end
      else begin // macOS 11.0 and above
        __ElementsUIKitForMacVersion[1] := __ElementsPlatformVersion[1]+3; // 11 -> 14
        __ElementsUIKitForMacVersion[2] := case __ElementsPlatformVersion[1] of
          11: __ElementsPlatformVersion[2]+2; // 11.0 -> 14.2, 11.1 -> 14.3
        12: if __ElementsPlatformVersion[2] < 2 then 0 else if __ElementsPlatformVersion[2] < 2 then __ElementsPlatformVersion[2]-1 else __ElementsPlatformVersion[2]-2;
        13: if __ElementsPlatformVersion[2] < 2 then 0 else __ElementsPlatformVersion[2]-1; // 13.0/13.1 -> 16.0, 13.2 -> 16.1?
        else __ElementsPlatformVersion[2]; // (guesswork, until we know where macOS 14 goes
        end;
        __ElementsUIKitForMacVersion[3] := 0;
      end;
    end;

    exit;
  end;

  //
  // fallback, operatingSystemVersion is new in macOS 10.10, iOS 8,
  //
  {$IFDEF TARGET_OS_IPHONE}
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_8_0 then __ElementsPlatformVersion := [1, 8, 0, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_7_1 then __ElementsPlatformVersion := [1, 7, 1, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_7_0 then __ElementsPlatformVersion := [1, 7, 0, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_6_1 then __ElementsPlatformVersion := [1, 6, 1, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_6_0 then __ElementsPlatformVersion := [1, 6, 0, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_5_1 then __ElementsPlatformVersion := [1, 5, 1, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_5_0 then __ElementsPlatformVersion := [1, 5, 0, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_3 then __ElementsPlatformVersion := [1, 4, 3, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_2 then __ElementsPlatformVersion := [1, 4, 2, 0] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_1 then __ElementsPlatformVersion := [1, 4, 1, 0] else
    __ElementsPlatformVersion := [1, 4, 0, 0];
  exit;
  {$ENDIF}
  {$IFDEF TARGET_OS_MAC and not TARGET_OS_IPHONE}
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_10_1 then __ElementsPlatformVersion := [1, 10, 10, 1] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_9_2 then __ElementsPlatformVersion := [1, 10, 9, 2] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_9_1 then __ElementsPlatformVersion := [1, 10, 9, 1] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_4 then __ElementsPlatformVersion := [1, 10, 8, 4] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_3 then __ElementsPlatformVersion := [1, 10, 8, 3] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_2 then __ElementsPlatformVersion := [1, 10, 8, 2] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_1 then __ElementsPlatformVersion := [1, 10, 8, 1] else

  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_4 then __ElementsPlatformVersion := [1, 10, 7, 4] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_3 then __ElementsPlatformVersion := [1, 10, 7, 3] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_2 then __ElementsPlatformVersion := [1, 10, 7, 2] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_1 then __ElementsPlatformVersion := [1, 10, 7, 1] else

  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_8 then __ElementsPlatformVersion := [1, 10, 6, 8] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_6 then __ElementsPlatformVersion := [1, 10, 6, 6] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_5 then __ElementsPlatformVersion := [1, 10, 6, 5] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_4 then __ElementsPlatformVersion := [1, 10, 6, 4] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_3 then __ElementsPlatformVersion := [1, 10, 6, 3] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_2 then __ElementsPlatformVersion := [1, 10, 6, 2] else
  if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_1 then __ElementsPlatformVersion := [1, 10, 6, 1] else
    __ElementsPlatformVersion := [1, 10, 5, 0];
  exit;
  {$ENDIF}
end;

method __ElementsCocoaVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  __ElementsLoadCocoaVersion;
  if (aMaj > __ElementsPlatformVersion[1]) then exit false;
  if (aMaj = __ElementsPlatformVersion[1]) then begin
    if (aMin > __ElementsPlatformVersion[2]) then exit false;
    if (aMin = __ElementsPlatformVersion[2]) then begin
      if (aRev > __ElementsPlatformVersion[3]) then exit false;
    end;
  end;
  exit true;
end;

method __ElementsUIKitForMacVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  __ElementsLoadCocoaVersion;
  if (aMaj > __ElementsUIKitForMacVersion[1]) then exit false;
  if (aMaj = __ElementsUIKitForMacVersion[1]) then begin
    if (aMin > __ElementsUIKitForMacVersion[2]) then exit false;
    if (aMin = __ElementsUIKitForMacVersion[2]) then begin
      if (aRev > __ElementsUIKitForMacVersion[3]) then exit false;
    end;
  end;
  exit true;
end;

method __ElementsCocoaPlatformAndVersionAtLeast(aPlatformName: String; aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  case aPlatformName:lowercaseString of
    'tvos': {$IFDEF TARGET_OS_TV}exit __ElementsCocoaVersionAtLeast(aMaj, aMin, aRev){$ENDIF};
    'watchos': {$IFDEF TARGET_OS_WATCH}exit __ElementsCocoaVersionAtLeast(aMaj, aMin, aRev){$ENDIF};
    'ios', 'iphoneos', 'ipados': {$IFDEF TARGET_OS_UIKITFORMAC}exit __ElementsUIKitForMacVersionAtLeast(aMaj, aMin, aRev){$ELSEIF TARGET_OS_IPHONE}exit __ElementsCocoaVersionAtLeast(aMaj, aMin, aRev){$ENDIF};
    'macos', 'mac os x', 'os x', 'mac os': {$IFDEF TARGET_OS_MAC OR TARGET_OS_UIKITFORMAC}exit __ElementsCocoaVersionAtLeast(aMaj, aMin, aRev){$ENDIF};
    'uikitformac', 'uikit for mac', 'mac catalyst', 'maccatalyst', 'catalyst': {$IFDEF TARGET_OS_UIKITFORMAC}exit __ElementsUIKitForMacVersionAtLeast(aMaj, aMin, aRev){$ENDIF};
  end;
end;

method __ElementsCocoaVersionString: String;
begin
  __ElementsLoadCocoaVersion;
  exit NSString.stringWithFormat('%d.%d.%d', __ElementsPlatformVersion[1],__ElementsPlatformVersion[2],__ElementsPlatformVersion[3]);
end;

method __ElementsCocoaUIKitForMacVersionString: String;
begin
  __ElementsLoadCocoaVersion;
  exit NSString.stringWithFormat('%d.%d.%d', __ElementsUIKitForMacVersion[1],__ElementsUIKitForMacVersion[2],__ElementsUIKitForMacVersion[3]);
end;

method __ElementsCocoaVersion: array[0..2] of Integer;
begin
  __ElementsLoadCocoaVersion;
  result[0] := __ElementsPlatformVersion[1];
  result[1] := __ElementsPlatformVersion[2];
  result[2] := __ElementsPlatformVersion[3];
end;

method __ElementsCocoaPlatform: String;
begin
  {$IFDEF TARGET_OS_UIKITFORMAC}
  exit 'Mac Catalyst';
  {$ENDIF}
  {$IFDEF TARGET_OS_WATCH}
  exit 'watchOS';
  {$ENDIF}
  {$IFDEF TARGET_OS_TV}
  exit 'tvOS';
  {$ENDIF}
  {$IFDEF TARGET_OS_IPHONE and not TARGET_OS_WATCH and not TARGET_OS_TV}
  exit 'iOS';
  {$ENDIF}
  {$IFDEF TARGET_OS_MAC and not TARGET_OS_IPHONE}
  exit 'macOS';
  {$ENDIF}
end;

method __ElementsCocoaPlatformIs(aPlatformName: String): Boolean;
begin
  case aPlatformName:lowercaseString of
    'tvos': exit {$IFDEF TARGET_OS_TV}true{$ELSE}false{$ENDIF};
    'watchos': exit {$IFDEF TARGET_OS_WATCH}true{$ELSE}false{$ENDIF};
    'ios', 'iphoneos', 'ipados': exit {$IFDEF TARGET_OS_IPHONE OR TARGET_OS_UIKITFORMAC}true{$ELSE}false{$ENDIF};
    'mac os', 'macos', 'mac os x', 'os x': exit {$IFDEF TARGET_OS_MAC OR TARGET_OS_UIKITFORMAC}true{$ELSE}false{$ENDIF};
    'uikitformac', 'uikit for mac', 'mac catalyst', 'maccatalyst', 'catalyst': exit {$IFDEF TARGET_OS_IPHONE OR TARGET_OS_UIKITFORMAC}true{$ELSE}false{$ENDIF};
  end;
  exit false;
end;

end.