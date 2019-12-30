unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.OleCtrls, SHDocVw,uAuth,strutils, MSHTML,uFuncs;

const
  SMS_URL='https://www.becmd.com';
type
  Tfmain = class(TForm)
    Panel1: TPanel;
    Bar1: TStatusBar;
    Page1: TPageControl;
    tsWeb: TTabSheet;
    tsInfo: TTabSheet;
    btnhome: TButton;
    btnClose: TButton;
    Web1: TWebBrowser;
    MemoInfo: TMemo;
    Web2: TWebBrowser;
    btnForward: TButton;
    btnBack: TButton;
    Label1: TLabel;
    cmbInternal: TComboBox;
    cmbForeign: TComboBox;
    Label2: TLabel;
    cmbInternal2: TComboBox;
    cmbForeign2: TComboBox;
    cmbPageError: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure Web1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);
    procedure Web2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure btnhomeClick(Sender: TObject);
    procedure btnForwardClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure FormCreate(Sender: TObject);
    procedure cmbForeignChange(Sender: TObject);
    procedure cmbInternalChange(Sender: TObject);

    procedure Web1NavigateError(ASender: TObject; const pDisp: IDispatch;
      const URL, Frame, StatusCode: OleVariant; var Cancel: WordBool);
    procedure Web1ProgressChange(ASender: TObject; Progress,
      ProgressMax: Integer);
  private
    { Private declarations }
    firstLoad:boolean;
    function nopage(body:string):boolean;
    procedure showLoad();
    procedure AppException(Sender: TObject; E: Exception);
  public
    { Public declarations }
  end;

var
  fmain: Tfmain;

implementation

{$R *.dfm}
procedure TfMain.AppException(Sender: TObject; E: Exception);
begin
  //Application.ShowException(E);
  //Application.Terminate;
  bar1.Panels[1].Text:=e.Message;
  memoInfo.Lines.Add(e.Message);
  //Log(e.Message);
end;
procedure Tfmain.showLoad();
var
  say:string;
  doc:IHTMLDocument2;
begin
  say:='正在加载...请稍候！';
  bar1.Panels[0].Text:=say;
  memoInfo.Lines.Add(say);
  doc:=web1.Document as IHTMLDocument2;
  if(doc<>nil)and(firstLoad=false)then
  doc.body.innerHTML:='<p align="center"><b><font size="48" color="red">'+say+'</font></b></p>';
end;
function Tfmain.nopage(body:string):boolean;
var
  i:integer;
  err:string;
begin
  result:=true;
  for i := 0 to cmbPageError.Items.Count-1 do
  begin
    err:=cmbPageError.Items[i];
    if(pos(err,body)>0)then exit;
  end;
  result:=false;
end;
procedure Tfmain.btnBackClick(Sender: TObject);
begin
  web1.GoBack;
end;

procedure Tfmain.btnCloseClick(Sender: TObject);
begin
close();
end;

procedure Tfmain.btnhomeClick(Sender: TObject);
begin
  web1.GoHome;
end;

procedure Tfmain.cmbForeignChange(Sender: TObject);
var
  url,item:string;
  i,len:integer;
begin
  item:=cmbForeign2.Items[cmbForeign.ItemIndex];
  //i:=pos('http',item);
  //len:=length(item);
  //url:=rightstr(item,len-i+1);
  web1.Navigate(item);
  //cmbForeign.Text:=leftstr(item,i-1);
  showLoad();
end;

procedure Tfmain.cmbInternalChange(Sender: TObject);
var
  url,item:string;
  i,len:integer;
begin
  item:=cmbInternal2.Items[cmbInternal.ItemIndex];
  //i:=pos('http',item);
  //len:=length(item);
  //url:=rightstr(item,len-i+1);
  web1.Navigate(item);
  //cmbInternal.Text:=leftstr(item,i-1);
  showLoad();
end;

procedure Tfmain.btnForwardClick(Sender: TObject);
begin
  web1.GoForward;
end;

procedure Tfmain.FormCreate(Sender: TObject);
begin
  if not uAuth.authorize then  application.Terminate;
  firstLoad:=true;
  IEEmulator(11001);
  Application.OnException := AppException;
end;

procedure Tfmain.FormShow(Sender: TObject);
begin
  web1.silent:=true;
  page1.ActivePageIndex:=0;
  TWinControl(Web2).Visible:=False;
  web1.Navigate('blank');
  web1.Navigate(SMS_URL);
end;

procedure Tfmain.Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
var
  say:string;
  doc:IHTMLDocument2;
begin
  say:='正在加载...请稍候！';
  bar1.Panels[0].Text:=say;
  memoInfo.Lines.Add(say);
  doc:=web1.Document as IHTMLDocument2;
  //if(doc<>nil)then
  //doc.body.innerHTML:='<p align="center"><b><font size="48" color="red">'+say+'</font></b></p>';
end;

procedure Tfmain.Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  say,body:string;
  doc:IHTMLDocument2;
begin
  if(Web1.ReadyState<>READYSTATE_COMPLETE)then exit;
  firstLoad:=false;
  say:='加载完毕!';
  bar1.Panels[0].Text:=say;
  memoInfo.Lines.Add(say);
  doc:=web1.Document as IHTMLDocument2;
  body:=doc.body.innerText;
  if nopage(body) then
  begin
    //doc.body.innerText:='线路繁忙!';
    doc.body.innerHTML:='<p align="center"><b><font size="48" color="red">线路繁忙!</font></b></p>';
  end;
end;

procedure Tfmain.Web1NavigateError(ASender: TObject; const pDisp: IDispatch;
  const URL, Frame, StatusCode: OleVariant; var Cancel: WordBool);
begin
  bar1.Panels[1].Text:=StatusCode;
end;

procedure Tfmain.Web1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
begin
  ppDisp := web2.Application; // 新的窗口先指向WebBrowser2
end;

procedure Tfmain.Web1ProgressChange(ASender: TObject; Progress,
  ProgressMax: Integer);
begin
  bar1.Panels[1].Text:=inttostr(Progress)+'/'+inttostr(ProgressMax);
end;

procedure Tfmain.Web2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  web1.Navigate(string(URL)); // 再指回WebBrowser1
  Cancel := True;
end;

end.
