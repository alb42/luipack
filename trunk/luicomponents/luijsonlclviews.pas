unit LuiJSONLCLViews;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, Controls, StdCtrls, ExtCtrls;

type

  TJSONObjectViewManager = class;

  TJSONMediatorState = set of (jmsLoading);

  { TCustomJSONGUIMediator }

  TCustomJSONGUIMediator = class
  public
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String; Control: TControl; OptionsData: TJSONObject); virtual;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject; const PropName: String; OptionsData: TJSONObject); virtual;
  end;

  TCustomJSONGUIMediatorClass = class of TCustomJSONGUIMediator;

  { TJSONGenericMediator }

  TJSONGenericMediator = class(TCustomJSONGUIMediator)
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String;
      Control: TControl; OptionsData: TJSONObject); override;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject;
      const PropName: String; OptionsData: TJSONObject); override;
  end;

  { TJSONCaptionMediator }

  TJSONCaptionMediator = class(TCustomJSONGUIMediator)
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String;
      Control: TControl; OptionsData: TJSONObject); override;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject;
      const PropName: String; OptionsData: TJSONObject); override;
  end;

  { TJSONSpinEditMediator }

  TJSONSpinEditMediator = class(TCustomJSONGUIMediator)
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String;
      Control: TControl; OptionsData: TJSONObject); override;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject;
      const PropName: String; OptionsData: TJSONObject); override;
  end;

  { TJSONRadioGroupMediator }

  TJSONRadioGroupMediator = class(TCustomJSONGUIMediator)
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String;
      Control: TControl; OptionsData: TJSONObject); override;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject;
      const PropName: String; OptionsData: TJSONObject); override;
  end;

  { TJSONCheckBoxMediator }

  TJSONCheckBoxMediator = class(TCustomJSONGUIMediator)
    class procedure DoJSONToGUI(Data: TJSONObject; const PropName: String;
      Control: TControl; OptionsData: TJSONObject); override;
    class procedure DoGUIToJSON(Control: TControl; Data: TJSONObject;
      const PropName: String; OptionsData: TJSONObject); override;
  end;

  { TJSONObjectPropertyView }

  TJSONObjectPropertyView = class(TCollectionItem)
  private
    FControl: TControl;
    FMediatorClass: TCustomJSONGUIMediatorClass;
    FMediatorId: String;
    FOptions: String;
    FOptionsData: TJSONObject;
    FPropertyName: String;
    procedure MediatorClassNeeded;
    procedure OptionsDataNeeded;
    procedure SetControl(Value: TControl);
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function GetDisplayName: string; override;
    procedure Load(JSONObject: TJSONObject);
    procedure Save(JSONObject: TJSONObject);
  published
    property Control: TControl read FControl write SetControl;
    property MediatorId: String read FMediatorId write FMediatorId;
    property Options: String read FOptions write FOptions;
    property PropertyName: String read FPropertyName write FPropertyName;
  end;

  { TJSONObjectPropertyViews }

  TJSONObjectPropertyViews = class(TCollection)
  private
    FOwner: TJSONObjectViewManager;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TJSONObjectViewManager);
  end;

  { TJSONObjectViewManager }

  TJSONObjectViewManager = class(TComponent)
  private
    FJSONObject: TJSONObject;
    FPropertyViews: TJSONObjectPropertyViews;
    FState: TJSONMediatorState;
    procedure SetJSONObject(const Value: TJSONObject);
    procedure SetPropertyViews(const Value: TJSONObjectPropertyViews);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load;
    procedure Load(const Properties: array of String);
    procedure Save;
    procedure Save(const Properties: array of String);
    property JSONObject: TJSONObject read FJSONObject write SetJSONObject;
    property State: TJSONMediatorState read FState;
  published
    property PropertyViews: TJSONObjectPropertyViews read FPropertyViews write SetPropertyViews;
  end;

  procedure RegisterJSONMediator(const MediatorId: String; MediatorClass: TCustomJSONGUIMediatorClass);
  procedure RegisterJSONMediator(ControlClass: TControlClass; MediatorClass: TCustomJSONGUIMediatorClass);

implementation

uses
  contnrs, LuiJSONUtils, strutils, spin, typinfo;

type

  { TJSONGUIMediatorManager }

  TJSONGUIMediatorManager = class
  private
    FList: TFPHashList;
  public
    constructor Create;
    destructor Destroy; override;
    function Find(const MediatorId: String): TCustomJSONGUIMediatorClass;
    procedure RegisterMediator(const MediatorId: String; MediatorClass: TCustomJSONGUIMediatorClass);
  end;

var
  MediatorManager: TJSONGUIMediatorManager;

procedure RegisterJSONMediator(const MediatorId: String;
  MediatorClass: TCustomJSONGUIMediatorClass);
begin
  MediatorManager.RegisterMediator(MediatorId, MediatorClass);
end;

procedure RegisterJSONMediator(ControlClass: TControlClass;
  MediatorClass: TCustomJSONGUIMediatorClass);
begin
  RegisterJSONMediator(ControlClass.ClassName, MediatorClass);
end;

{ TJSONCheckBoxMediator }

class procedure TJSONCheckBoxMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
var
  CheckBox: TCheckBox;
  PropData: TJSONData;
begin
  //todo: add checked/unchecked options
  CheckBox := Control as TCheckBox;
  CheckBox.Checked := Data.Get(PropName, False);
end;

class procedure TJSONCheckBoxMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
var
  CheckBox: TCheckBox;
begin
  CheckBox := Control as TCheckBox;
  if CheckBox.Checked then
    Data.Booleans[PropName] := True
  else
    Data.Delete(PropName);
end;

{ TJSONRadioGroupMediator }

class procedure TJSONRadioGroupMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
var
  RadioGroup: TRadioGroup;
  PropData: TJSONData;
  NewIndex: Integer;
begin
  RadioGroup := Control as TRadioGroup;
  PropData := Data.Find(PropName);
  if (PropData <> nil) and (PropData.JSONType <> jtNull) then
  begin
    //todo make options TJSONObject
    if (OptionsData <> nil) and OptionsData.Get('useindex', False) then
    begin
      if PropData.JSONType = jtNumber then
      begin
        NewIndex := PropData.AsInteger;
        if (NewIndex >= 0) and (NewIndex < RadioGroup.Items.Count) then
          RadioGroup.ItemIndex := NewIndex
        else
          RadioGroup.ItemIndex := -1;
      end;
    end
    else
    begin
      if PropData.JSONType = jtString then
        RadioGroup.ItemIndex := RadioGroup.Items.IndexOf(PropData.AsString);
    end;
  end
  else
    RadioGroup.ItemIndex := -1;
end;

class procedure TJSONRadioGroupMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
var
  RadioGroup: TRadioGroup;
  PropData: TJSONData;
begin
  RadioGroup := Control as TRadioGroup;
  if RadioGroup.ItemIndex <> -1 then
  begin
    if (OptionsData <> nil) and OptionsData.Get('useindex', False) then
      Data.Integers[PropName] := RadioGroup.ItemIndex
    else
      Data.Strings[PropName] := RadioGroup.Items[RadioGroup.ItemIndex]
  end
  else
    Data.Delete(PropName);
end;

{ TJSONSpinEditMediator }

class procedure TJSONSpinEditMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
var
  PropData: TJSONData;
  SpinEdit: TCustomFloatSpinEdit;
begin
  SpinEdit := Control as TCustomFloatSpinEdit;
  PropData := Data.Find(PropName);
  if (PropData = nil) or (PropData.JSONType = jtNull) then
    SpinEdit.ValueEmpty := True
  else
  begin
    SpinEdit.Value := PropData.AsFloat;
    SpinEdit.ValueEmpty := False;
  end;
end;

class procedure TJSONSpinEditMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
var
  SpinEdit: TCustomFloatSpinEdit;
begin
  SpinEdit := Control as TCustomFloatSpinEdit;
  if not SpinEdit.ValueEmpty then
  begin
    if SpinEdit.DecimalPlaces = 0 then
      Data.Integers[PropName] := round(SpinEdit.Value)
    else
      Data.Floats[PropName] := SpinEdit.Value;
  end
  else
  begin
    //todo add option to configure undefined/null
    Data.Delete(PropName);
    //JSONObject.Nulls[PropName] := True;
  end;
end;

{ TJSONGUIMediatorStore }

constructor TJSONGUIMediatorManager.Create;
begin
  FList := TFPHashList.Create;
end;

destructor TJSONGUIMediatorManager.Destroy;
begin
  FList.Destroy;
  inherited Destroy;
end;

function TJSONGUIMediatorManager.Find(const MediatorId: String): TCustomJSONGUIMediatorClass;
begin
  Result := TCustomJSONGUIMediatorClass(FList.Find(MediatorId));
end;

procedure TJSONGUIMediatorManager.RegisterMediator(const MediatorId: String;
  MediatorClass: TCustomJSONGUIMediatorClass);
begin
  FList.Add(MediatorId, MediatorClass);
end;

{ TJSONObjectViewManager }

procedure TJSONObjectViewManager.SetPropertyViews(const Value: TJSONObjectPropertyViews);
begin
  FPropertyViews.Assign(Value);
end;

procedure TJSONObjectViewManager.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: Integer;
  View: TJSONObjectPropertyView;
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    for i := 0 to FPropertyViews.Count -1 do
    begin
      View := TJSONObjectPropertyView(FPropertyViews.Items[i]);
      if AComponent = View.Control then
        View.Control := nil;
    end;
  end;
end;

procedure TJSONObjectViewManager.SetJSONObject(const Value: TJSONObject);
begin
  if FJSONObject = Value then exit;
  FJSONObject := Value;
end;

constructor TJSONObjectViewManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPropertyViews := TJSONObjectPropertyViews.Create(Self);
end;

destructor TJSONObjectViewManager.Destroy;
begin
  FPropertyViews.Destroy;
  inherited Destroy;
end;

procedure TJSONObjectViewManager.Load;
var
  i: Integer;
  View: TJSONObjectPropertyView;
begin
  Include(FState, jmsLoading);
  try
    for i := 0 to FPropertyViews.Count - 1 do
    begin
      View := TJSONObjectPropertyView(FPropertyViews.Items[i]);
      View.Load(FJSONObject);
    end;
  finally
    Exclude(FState, jmsLoading);
  end;
end;

procedure TJSONObjectViewManager.Load(const Properties: array of String);
var
  i: Integer;
  View: TJSONObjectPropertyView;
begin
  Include(FState, jmsLoading);
  try
    for i := 0 to FPropertyViews.Count - 1 do
    begin
      View := TJSONObjectPropertyView(FPropertyViews.Items[i]);
      if AnsiMatchText(View.PropertyName, Properties) then
        View.Load(FJSONObject);
    end;
  finally
    Exclude(FState, jmsLoading);
  end;
end;

procedure TJSONObjectViewManager.Save;
var
  i: Integer;
  View: TJSONObjectPropertyView;
begin
  for i := 0 to FPropertyViews.Count -1 do
  begin
    View := TJSONObjectPropertyView(FPropertyViews.Items[i]);
    View.Save(FJSONObject);
  end;
end;

procedure TJSONObjectViewManager.Save(const Properties: array of String);
var
  i: Integer;
  View: TJSONObjectPropertyView;
begin
  for i := 0 to FPropertyViews.Count -1 do
  begin
    View := TJSONObjectPropertyView(FPropertyViews.Items[i]);
    if AnsiMatchText(View.PropertyName, Properties) then
      View.Save(FJSONObject);
  end;
end;

{ TJSONObjectPropertyViews }

function TJSONObjectPropertyViews.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

constructor TJSONObjectPropertyViews.Create(AOwner: TJSONObjectViewManager);
begin
  inherited Create(TJSONObjectPropertyView);
  FOwner := AOwner;
end;

{ TJSONObjectPropertyView }

procedure TJSONObjectPropertyView.MediatorClassNeeded;
begin
  if FMediatorClass = nil then
  begin
    if FMediatorId <> '' then
      FMediatorClass := MediatorManager.Find(FMediatorId)
    else
      FMediatorClass := MediatorManager.Find(Control.ClassName);
    if FMediatorClass = nil then
      raise Exception.CreateFmt('Could not find mediator (MediatorId: "%s" ControlClass: "%s")', [FMediatorId, Control.ClassName]);
  end;
end;

procedure TJSONObjectPropertyView.OptionsDataNeeded;
begin
  if (FOptions <> '') and (FOptionsData = nil) then
    StringToJSONData(FOptions, FOptionsData);
end;

procedure TJSONObjectPropertyView.SetControl(Value: TControl);
var
  TheOwner: TComponent;
begin
  if FControl = Value then Exit;
  TheOwner := Collection.Owner as TComponent;
  if (TheOwner <> nil) then
  begin
    if FControl <> nil then
      FControl.RemoveFreeNotification(TheOwner);
    if Value <> nil then
      Value.FreeNotification(TheOwner);
  end;
  FControl := Value;
end;

destructor TJSONObjectPropertyView.Destroy;
begin
  FOptionsData.Free;
  inherited Destroy;
end;

procedure TJSONObjectPropertyView.Assign(Source: TPersistent);
begin
  if Source is TJSONObjectPropertyView then
  begin
    PropertyName := TJSONObjectPropertyView(Source).PropertyName;
    Control := TJSONObjectPropertyView(Source).Control;
    Options := TJSONObjectPropertyView(Source).Options;
    MediatorId := TJSONObjectPropertyView(Source).MediatorId;
  end
  else
    inherited Assign(Source);
end;

function TJSONObjectPropertyView.GetDisplayName: string;
begin
  Result := FPropertyName;
  if Result = '' then
    Result := ClassName;
end;

procedure TJSONObjectPropertyView.Load(JSONObject: TJSONObject);
begin
  if FControl <> nil then
  begin
    //todo handle mediator and options loading once
    MediatorClassNeeded;
    OptionsDataNeeded;
    FMediatorClass.DoJSONToGUI(JSONObject, FPropertyName, FControl, FOptionsData);
  end;
end;

procedure TJSONObjectPropertyView.Save(JSONObject: TJSONObject);
begin
  if FControl <> nil then
  begin
    //todo handle mediator and options loading once
    MediatorClassNeeded;
    OptionsDataNeeded;
    FMediatorClass.DoGUIToJSON(FControl, JSONObject, FPropertyName, FOptionsData);
  end;
end;

{ TCustomJSONGUIMediator }

class procedure TCustomJSONGUIMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
begin
  //
end;

class procedure TCustomJSONGUIMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
begin
  //
end;

{ TJSONGenericMediator }

type
  TControlAccess = class(TControl)

  end;

class procedure TJSONGenericMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
begin
  TControlAccess(Control).Text := GetJSONProp(Data, PropName, '');
end;

class procedure TJSONGenericMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
var
  i: Integer;
  ControlText: String;
begin
  i := Data.IndexOfName(PropName);
  ControlText := TControlAccess(Control).Text;
  if (i <> -1) or (ControlText <> '') then
    Data.Strings[PropName] := ControlText;
end;

{ TJSONCaptionMediator }

class procedure TJSONCaptionMediator.DoJSONToGUI(Data: TJSONObject;
  const PropName: String; Control: TControl; OptionsData: TJSONObject);
var
  FormatStr, TemplateStr, ValueStr: String;
  PropData: TJSONData;
begin
  PropData := Data.Find(PropName);
  if PropData <> nil then
    ValueStr := PropData.AsString
  else
    ValueStr := '';
  if OptionsData <> nil then
  begin
    if PropData <> nil then
    begin
      FormatStr := OptionsData.Get('format', '');
      if FormatStr = 'date' then
        ValueStr := DateToStr(PropData.AsFloat)
      else if FormatStr = 'datetime' then
        ValueStr := DateTimeToStr(PropData.AsFloat);
    end;
    TemplateStr := OptionsData.Get('template', '%s');
    Control.Caption := Format(TemplateStr, [ValueStr]);
  end
  else
    Control.Caption := ValueStr;
end;

class procedure TJSONCaptionMediator.DoGUIToJSON(Control: TControl;
  Data: TJSONObject; const PropName: String; OptionsData: TJSONObject);
begin
  //
end;

initialization
  MediatorManager := TJSONGUIMediatorManager.Create;
  RegisterJSONMediator(TEdit, TJSONGenericMediator);
  RegisterJSONMediator(TMemo, TJSONGenericMediator);
  RegisterJSONMediator(TComboBox, TJSONGenericMediator);
  RegisterJSONMediator(TLabel, TJSONCaptionMediator);
  RegisterJSONMediator(TSpinEdit, TJSONSpinEditMediator);
  RegisterJSONMediator(TFloatSpinEdit, TJSONSpinEditMediator);
  RegisterJSONMediator(TRadioGroup, TJSONRadioGroupMediator);
  RegisterJSONMediator(TCheckBox, TJSONCheckBoxMediator);

finalization
  MediatorManager.Destroy;

end.

