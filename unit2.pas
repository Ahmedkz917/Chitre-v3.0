unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DividerBevel,
  LCLIntf;  // Pour OpenURL

type

  { TForm2 }

  TForm2 = class(TForm)
    DividerBevel1: TDividerBevel;
    Image1: TImage;
    Label1: TLabel;
    lblemail: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblemailClick(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  lblEmail.Font.Color := clBlue;
  lblEmail.Font.Style := [fsUnderline];
  lblEmail.Cursor := crHandPoint;
end;

procedure TForm2.lblemailClick(Sender: TObject);
begin
  OpenURL('mailto:' + lblEmail.Caption + '?subject=Convertisseur Montant en Lettres')

end;

end.

