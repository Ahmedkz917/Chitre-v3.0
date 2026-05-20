unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  Clipbrd, ExtCtrls, StrUtils, LCLType, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    edtMontant: TEdit;
    cbDevise: TComboBox;
    lblDevise: TLabel;
    lblMontant: TLabel;
    memoResultat: TMemo;
    btnConvertir: TSpeedButton;
    btnCopier: TSpeedButton;
    btnNouveau: TSpeedButton;
    btnAPropos: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    lblFormat: TLabel;
    btnPast: TSpeedButton;
    btnQuitter: TSpeedButton;

    procedure btnPastClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edtMontantKeyPress(Sender: TObject; var Key: char);
    procedure edtMontantChange(Sender: TObject);
    procedure edtMontantExit(Sender: TObject);
    procedure btnConvertirClick(Sender: TObject);
    procedure btnCopierClick(Sender: TObject);
    procedure btnNouveauClick(Sender: TObject);
    procedure btnQuitterClick(Sender: TObject);
    procedure btnAProposClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    function CleanMontant(const Texte: string): string;
    function PartieEntiereEnLettres(N: Int64): string;
    function GetDeviseSingPlur(Devise: string; Nombre: Int64): string;
    function NombreEnLettres(Montant: Double; const Devise: string): string;
    function ToTitleCase(const S: string): string;   // Nouvelle fonction
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

// ==================== NETTOYAGE MONTANT ====================
function TForm1.CleanMontant(const Texte: string): string;
var
  Sep: Char;
begin
  Result := Texte;
  Sep := FormatSettings.DecimalSeparator;
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]); // espace insécable
  Result := StringReplace(Result, '.', Sep, [rfReplaceAll]);
  Result := StringReplace(Result, ',', Sep, [rfReplaceAll]);
end;

// ==================== CHIFFRE EN LETTRES ====================
function TForm1.PartieEntiereEnLettres(N: Int64): string;
const
  Unites: array[0..19] of string = ('', 'un', 'deux', 'trois', 'quatre', 'cinq',
    'six', 'sept', 'huit', 'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze',
    'quinze', 'seize', 'dix-sept', 'dix-huit', 'dix-neuf');

  Dizaines: array[2..9] of string = ('vingt', 'trente', 'quarante', 'cinquante',
    'soixante', 'soixante-dix', 'quatre-vingt', 'quatre-vingt-dix');
begin
  Result := '';
  if N = 0 then Exit('zéro');

  if N >= 1000000000 then
  begin
    Result := PartieEntiereEnLettres(N div 1000000000) + ' milliard';
    if (N div 1000000000 > 1) then Result := Result + 's';
    if (N mod 1000000000 <> 0) then Result := Result + ' ' + PartieEntiereEnLettres(N mod 1000000000);
    Exit;
  end;

  if N >= 1000000 then
  begin
    Result := PartieEntiereEnLettres(N div 1000000) + ' million';
    if (N div 1000000 > 1) then Result := Result + 's';
    if (N mod 1000000 <> 0) then Result := Result + ' ' + PartieEntiereEnLettres(N mod 1000000);
    Exit;
  end;

  if N >= 1000 then
  begin
    if (N div 1000) = 1 then Result := 'mille'
    else Result := PartieEntiereEnLettres(N div 1000) + ' mille';
    if (N mod 1000 <> 0) then Result := Result + ' ' + PartieEntiereEnLettres(N mod 1000);
    Exit;
  end;

  if N >= 100 then
  begin
    if (N div 100) = 1 then Result := 'cent'
    else Result := Unites[N div 100] + ' cent';
    if (N mod 100 <> 0) then Result := Result + ' ' + PartieEntiereEnLettres(N mod 100);
    Exit;
  end;

  if N >= 20 then
  begin
    if (N div 10 = 7) or (N div 10 = 9) then
    begin
      Result := Dizaines[N div 10];
      if (N mod 10 <> 0) then
        Result := Result + '-' + Unites[N mod 10];
    end
    else
    begin
      Result := Dizaines[N div 10];
      if (N mod 10 <> 0) then
        Result := Result + '-' + Unites[N mod 10];
    end;

    if N = 80 then Result := 'quatre-vingts';
  end
  else
    Result := Unites[N];
end;

function TForm1.GetDeviseSingPlur(Devise: string; Nombre: Int64): string;
begin
  if Devise = '' then Exit('');

  Devise := LowerCase(Devise);
  if (Devise = 'euro') or (Devise = 'euros') then
    Result := IfThen(Nombre > 1, 'euros', 'euro')
  else if (Devise = 'dollar') or (Devise = 'dollars') then
    Result := IfThen(Nombre > 1, 'dollars', 'dollar')
  else if (Devise = 'dinar') or (Devise = 'dinars') then
    Result := IfThen(Nombre > 1, 'dinars', 'dinar')
  else if (Devise = 'livre') or (Devise = 'livres') then
    Result := IfThen(Nombre > 1, 'livres', 'livre')
  else if (Devise = 'dirham') or (Devise = 'dirhams') then
    Result := IfThen(Nombre > 1, 'dirhams', 'dirham')
  else
    Result := Devise + IfThen(Nombre > 1, 's', '');
end;

function TForm1.ToTitleCase(const S: string): string;
var
  i: Integer;
  PrevSpace: Boolean;
begin
  Result := LowerCase(S);
  PrevSpace := True;
  for i := 1 to Length(Result) do
  begin
    if PrevSpace and (Result[i] in ['a'..'z']) then
      Result[i] := UpCase(Result[i]);
    PrevSpace := Result[i] = ' ';
  end;
end;

function TForm1.NombreEnLettres(Montant: Double; const Devise: string): string;
var
  Entier, Centimes: Int64;
  S: string;
begin
  Entier := Trunc(Montant);
  Centimes := Round(Frac(Montant) * 100);

  S := PartieEntiereEnLettres(Entier);

  if Entier > 0 then
    S := S + ' ' + GetDeviseSingPlur(Devise, Entier);

  if Centimes > 0 then
  begin
    if Entier > 0 then
      S := S + ', et '          // ← Changé comme demandé
    else
      S := S + ' ';
    S := S + PartieEntiereEnLettres(Centimes) + ' centime';
    if Centimes > 1 then S := S + 's';
  end;

  if (Entier = 0) and (Centimes = 0) then
    S := 'zéro ' + GetDeviseSingPlur(Devise, 0);

  Result := ToTitleCase(S);   // Mise en majuscule de chaque mot
end;

// ==================== SAISIE ====================
procedure TForm1.edtMontantKeyPress(Sender: TObject; var Key: char);
var
  Sep: Char;
  PosSep, DecimalsCount: Integer;
begin
  Sep := FormatSettings.DecimalSeparator;

  if Key = #13 then
  begin
    btnConvertirClick(nil);
    Key := #0;
    Exit;
  end;

  if not (Key in ['0'..'9', Sep, '.', ',', #8]) then
  begin
    Key := #0;
    Exit;
  end;

  if (Key in ['.', ',']) then
  begin
    if Pos(Sep, edtMontant.Text) > 0 then Key := #0
    else Key := Sep;
    Exit;
  end;

  if (Key in ['0'..'9']) then
  begin
    PosSep := Pos(Sep, edtMontant.Text);
    if PosSep > 0 then
    begin
      DecimalsCount := Length(edtMontant.Text) - PosSep;
      if (DecimalsCount >= 2) then Key := #0;
    end;
  end;
end;

procedure TForm1.edtMontantChange(Sender: TObject);
begin
  // Peut rester vide ou tu peux y mettre un formatage live si tu veux
end;

procedure TForm1.edtMontantExit(Sender: TObject);
var
  S: string;
  Montant: Double;
begin
  S := CleanMontant(edtMontant.Text);
  if TryStrToFloat(S, Montant) then
    edtMontant.Text := FormatFloat('#,##0.00', Montant)
  else
    edtMontant.Text := '';
end;

// ==================== BOUTONS ====================
procedure TForm1.btnConvertirClick(Sender: TObject);
var
  Montant: Double;
  S: string;
begin
  S := CleanMontant(edtMontant.Text);
  if not TryStrToFloat(S, Montant) then
  begin
    ShowMessage('Rien a Convertire ou Montant invalide !');
    edtMontant.SetFocus;
    Exit;
  end;

  memoResultat.Text := NombreEnLettres(Montant, cbDevise.Text);
  memoResultat.SetFocus;
end;

procedure TForm1.btnCopierClick(Sender: TObject);
begin
  if memoResultat.Text <> '' then
  begin
    Clipboard.AsText := memoResultat.Text;
    ShowMessage('✔ Copié dans le presse-papiers !');
  end;
end;

procedure TForm1.btnNouveauClick(Sender: TObject);
begin
  edtMontant.Clear;
  memoResultat.Clear;
  edtMontant.SetFocus;
end;


procedure TForm1.btnAProposClick(Sender: TObject);
begin
  form2.showmodal;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key = VK_ESCAPE then
  begin
    btnNouveauClick(nil);
    Key := 0;               // Consomme la touche
  end;
end;

procedure TForm1.btnQuitterClick(Sender: TObject);
begin
    Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  cbDevise.Items.AddStrings(['', 'Euro', 'Dollar', 'Dinar', 'Livre', 'Dirham', 'Riyal']);
  cbDevise.ItemIndex := 0;

  edtMontant.Clear;
  memoResultat.Clear;

  btnConvertir.Caption := 'Convertir';
  btnCopier.Caption := 'Copier';
  btnNouveau.Caption := 'Nouveau';
  btnQuitter.Caption := 'Quitter';
  btnAPropos.Caption := 'À propos';
end;

procedure TForm1.btnPastClick(Sender: TObject);
begin
    edtMontant.Text:= Clipboard.AsText;
  end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    if MessageDlg('Merci d''avoir utilisé cette application !', mtInformation, [mbOk], 0) = mrYes then
end;


end.
