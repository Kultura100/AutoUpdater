unit Unit20;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani, FMX.Layouts, FMX.Gestures,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects,Winapi.Windows,ShellApi,TlHelp32,wininet,UrlMon, ActiveX,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, FMX.Effects,
  FMX.Filter.Effects, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP;

 type
TCallbackObject = class(TObject, IBindStatusCallBack)
  public
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function OnStartBinding(dwReserved: DWORD; pib: IBinding): HResult; stdcall;
    function GetBindInfo(out grfBINDF: DWORD; var bindinfo: TBindInfo): HResult; stdcall;
    function OnStopBinding(hresult: HResult; szError: LPCWSTR): HResult; stdcall;
    function GetPriority(out nPriority): HResult; stdcall;
    function OnLowResource(reserved: DWORD): HResult; stdcall;
    function OnDataAvailable(grfBSCF: DWORD; dwSize: DWORD; formatetc: PFormatEtc; stgmed: PStgMedium): HResult; stdcall;
    function OnObjectAvailable(const IID: TGUID; punk: IUnknown): HResult; stdcall;
    function OnProgress(ulProgress, ulProgressMax, ulStatusCode: ULONG; szStatusText: LPCWSTR): HResult; stdcall;
  end;

type
  TForm20 = class(TForm)
    Button2: TCornerButton;
    ProgressBar1: TProgressBar;
    Text1: TText;
    StyleBook1: TStyleBook;
    Timer1: TTimer;
    BindingsList1: TBindingsList;
    Image1: TImage;
    ShadowEffect1: TShadowEffect;
    InvertEffect1: TInvertEffect;
    Bitmap: TBitmapAnimation;
    Timer2: TTimer;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form20: TForm20;
  Cancel: Boolean = False;
  Aktualizacja:Boolean;


  const
  url : PWideChar = 'https://kultura-programowania.pl/download/HistoriaSztuki/HistoriaSztuki.exe';
  version : String = '1.2.0.2';
  urlupdater: PWideChar = 'https://kultura-programowania.pl/download/HistoriaSztuki/Aktualizator.exe';
  urlu: PWideChar = 'https://kultura-programowania.pl/download/HistoriaSztuki/upgrader/version.css';

implementation

{$R *.fmx}


procedure zakonczonopobieranie();
begin
form20.Text1.Text:='Pobieranie zosta³o zakoñczone pomyœlnie';
form20.Bitmap.Enabled:=True;
if not (Aktualizacja) then form20.Timer1.Enabled:=True //pamietac do updatera
else
form20.Timer2.Enabled:=True;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function TCallbackObject._AddRef: Integer;
begin
result:=S_OK;
end;

function TCallbackObject._Release: Integer;
begin
result:=S_OK;
end;

function TCallbackObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
if(GetInterface(IID,Obj)) then
  result:=S_OK
else
  result:=E_NOINTERFACE;
end;

function TCallbackObject.OnStartBinding(dwReserved: DWORD; pib: IBinding): HResult;
begin
result:=S_OK;
end;

function TCallbackObject.GetBindInfo(out grfBINDF: DWORD; var bindinfo: TBindInfo): HResult; stdcall;
begin
result:=S_OK;
end;

function TCallbackObject.OnStopBinding(hresult: HResult; szError: LPCWSTR): HResult; stdcall;
begin
result:=S_OK;
end;

function TCallbackObject.GetPriority(out nPriority): HResult;
begin
result:=S_OK;
end;

function TCallbackObject.OnLowResource(reserved: DWORD): HResult;
begin
result:=S_OK;
end;

function TCallbackObject.OnDataAvailable(grfBSCF: DWORD; dwSize: DWORD; formatetc: PFormatEtc; stgmed: PStgMedium): HResult;
begin
result:=S_OK;
end;

function TCallbackObject.OnObjectAvailable(const IID: TGUID; punk: IUnknown): HResult; stdcall;
begin
result:=S_OK;
end;

function TCallbackObject.OnProgress(ulProgress, ulProgressMax, ulStatusCode: ULONG; szStatusText: LPCWSTR): HResult;
begin
case ulStatusCode of
  BINDSTATUS_FINDINGRESOURCE:
    begin
    Form20.Text1.Text:='Nawi¹zywanie po³¹czenia';
    Form20.Button2.Visible:=False;
    if (Cancel) then
      begin
      result:=E_ABORT;
      exit;
      end;
    end;
  BINDSTATUS_CONNECTING:
    begin
    if (Cancel) then
      begin
      Form20.Text1.Text:='Anulowano przy ³¹czeniu';
      Form20.Button2.Visible:=False;
      //form20.Timer1.Enabled:=True;
       form20.Close;
      result:=E_ABORT;
      exit;
      end
    else
      Form20.Text1.Text:='£¹czenie..';

    end;
  BINDSTATUS_BEGINDOWNLOADDATA:
    begin
    Form20.ProgressBar1.Visible:=False;

    if (Cancel) then
      begin
      Form20.Text1.Text:='Anulowano przy przygotowaniu pobierania!';
      Form20.Button2.Visible:=False;
      //form20.Timer1.Enabled:=True;
      form20.Close;
      result:=E_ABORT;
      exit;
      end
    else
      begin
        Form20.Text1.Text:='Rozpoczynam pobieranie..';
        form20.ProgressBar1.visible:=True;
        Form20.Button2.Visible:=True;
      end;
    end;
  BINDSTATUS_DOWNLOADINGDATA:
    begin
    if (Cancel) then
      begin
      Form20.Text1.Text:='Anulowano przy pobieraniu!';
      Form20.Button2.Visible:=False;
      form20.Close;
      result:=E_ABORT;
      exit;
      end
    else
      begin
      form20.ProgressBar1.Max:=ulProgressMax;
      form20.Progressbar1.value:=ulProgress;
      if(unit20.Aktualizacja) then form20.Text1.Text:='Autoaktualizacja ( '+inttostr(ulProgress div 1024)+'kB / '+inttostr(ulProgressMax div 1024)+'kB )'
      else
      form20.Text1.Text:='Trwa pobieranie ( '+inttostr(ulProgress div 1024)+'kB / '+inttostr(ulProgressMax div 1024)+'kB )';
      end;
    end;
  BINDSTATUS_ENDDOWNLOADDATA:
    begin
    //form20.ProgressBar1.Visible:=False;
    form20.Button2.Visible:=False;
    zakonczonopobieranie();
    end;
end;
Application.ProcessMessages;
result:=S_OK;
end;

procedure zacznijpobieranie();
var
  CallBack:TCallbackObject;
begin
  if form20.button2.Text='Przerwij' then
  begin
  KillTask('HistoriaSztuki.exe');
  Form20.Button2.Text:='Przerwij ';
    CallBack := TCallBackObject.Create;
    try
      DeleteUrlCacheEntry(URL);
      URLDownloadToFile(nil,URL,'HistoriaSztuki.exe',0,CallBack);
      finally
      CallBack.Free;
    end
  end else Cancel:=TRUE;
end;


procedure TForm20.Button2Click(Sender: TObject);
begin
zacznijpobieranie();
end;

procedure TForm20.FormActivate(Sender: TObject);
var
  pobrana:String;
  CallBack:TCallbackObject;
begin
pobrana:=idHTTP1.Get(urlu);
if FileExists('Aktualizatorold.exe') then DeleteFile('Aktualizatorold.exe');
  if(version <> pobrana) then
  begin
  Aktualizacja:=True;
    CallBack := TCallBackObject.Create;
      try
      DeleteUrlCacheEntry(urlupdater);
      RenameFile('Aktualizator.exe','Aktualizatorold.exe');
      URLDownloadToFile(nil,urlupdater,'Aktualizator.exe',0,CallBack);
      finally
      CallBack.Free;
    end
  end else zacznijpobieranie();
end;

procedure TForm20.Timer1Timer(Sender: TObject);
begin
Timer1.Enabled:=False;
ShellExecute(0, 'open','HistoriaSztuki.exe', nil, nil, SW_SHOWNORMAL);
form20.Close;
end;

procedure TForm20.Timer2Timer(Sender: TObject);
begin
Timer2.Enabled:=False;
ShellExecute(0, 'open','Aktualizator.exe', nil, nil, SW_SHOWNORMAL);
form20.Close;
end;

end.
