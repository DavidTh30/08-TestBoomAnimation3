unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, EpikTimer, BGRABitmap,BGRABitmapTypes, Math, LCLIntf;
  //Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  //ExtCtrls, EpikTimer,
  //BGRABitmap,BGRABitmapTypes,BGRACanvas2D,IntfGraphics,
  //FPImage, vlc, GraphType, Math, LCLIntf, LMessages, BGRAPath;

type
  Animation = record
    Life:Boolean;
    Index:Integer;
    AnimatType:Integer;
    Frame_Speed: Integer;
    Remain_Speed:Integer;
    TotalFrame: Integer;
    Actual_Frame: Integer;
    MovingSpeed:Tpoint;
    Angle:Extended;
    Position:Tpoint;
    Bitmap_: array of Integer;
  end;

  type
  Inform = record
    Previous: Float;
    TimePerFrame: Float;
    LinePerFrame: Integer;
    FramePerSec: Integer;
    ActualElapsed: Float;
    LineLeftover: Integer;
    Speed_frame:Extended;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label3: TLabel;
    PaintBox2: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure Main_Loop();
    Function TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
    procedure SetUpValue();
  end;

var
  Form1: TForm1;
  timer_: TEpikTimer;
  Run_:Boolean;
  Background_, bmp, bmp2: TBGRABitmap;
  Grid_:Tpoint;
  c: TBGRAPixel;
  Trect_:Trect;
  Positioning:Integer;
  Bomb: array of Animation; //Bomb: array[0..20] of Animation;
  BitmapAnimation: array of TBGRABitmap;
  Information:Inform;
  TotalBomb, TotalBitmapAnimation:integer;

implementation

{$R *.lfm}

{ TForm1 }
Procedure TForm1.SetUpValue();
var
  i, i2:integer;
begin
  Information.Speed_frame:=0.02;
  timer_ := TEpikTimer.Create(nil);
  Run_:=False;
  TotalBitmapAnimation:=13;
  setlength(BitmapAnimation,TotalBitmapAnimation);
  for i:=0 to TotalBitmapAnimation-1 do
      BitmapAnimation[i] := TransparentBMP_ToBuffer('explode'+IntToStr(i+1)+'.png');

  TotalBomb:=2000;
  setlength(Bomb,TotalBomb);
  Randomize;
  for i := 0 to TotalBomb-1 do
  begin
    Bomb[i].Life:=False;
    Bomb[i].Index:=i;
    Bomb[i].Actual_Frame:=0;
    Bomb[i].AnimatType:=0;
    Bomb[i].Frame_Speed:=3;
    Bomb[i].Remain_Speed:=Bomb[i].Frame_Speed;
    Bomb[i].MovingSpeed:=Point(0,0);
    Bomb[i].Position:=Point(0,0);
    Bomb[i].Angle:=0;
    Bomb[i].TotalFrame:=13;
    setlength(Bomb[i].Bitmap_,Bomb[i].TotalFrame);
    for i2:=0 to Bomb[i].TotalFrame-1 do
      Bomb[i].Bitmap_[i2] := i2;
    Bomb[i].Position.x:=Random(PaintBox2.Width-(BitmapAnimation[Bomb[i].Bitmap_[0]].Width));
    Bomb[i].Position.y:=Random(PaintBox2.Height-BitmapAnimation[Bomb[i].Bitmap_[0]].Height);
  end;

  for i:=0 to Random(Round(TotalBomb/3)) do
    if Random(2) = 1 then begin Bomb[i].Life:=True; Bomb[i].Actual_Frame:=Random(Bomb[i].TotalFrame); end;

end;

Function TForm1.TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
var
  OriginalBMP: TBGRABitmap;
  //Trect_:Trect;
begin
  OriginalBMP := TBGRABitmap.Create(filename);
  OriginalBMP.ReplaceColor(OriginalBMP.GetPixel(0,0),BGRAPixelTransparent);
  TransparentBMP_ToBuffer := TBGRABitmap.Create(OriginalBMP.Width,OriginalBMP.Height);       //result
  TransparentBMP_ToBuffer.PutImage(0,0,OriginalBMP,dmSet,255);
  //TransparentBMP_ToBuffer.Rectangle(OriginalBMP.Width,0,OriginalBMP.Width,OriginalBMP.Height,BGRABlack,BGRA(0,0,0,64),dmDrawWithTransparency);

  //Trect_.TopLeft.x:=0;
  //Trect_.TopLeft.y:=0;
  //Trect_.BottomRight.x:=round(OriginalBMP.Width/2);
  //Trect_.BottomRight.y:=round(OriginalBMP.Height/2);
  //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmSet,255); //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmDrawWithTransparency);
  OriginalBMP.Free;
end;

procedure TForm1.Main_Loop();
//Use Case 1 disable case 2; design for running one program only
//Use Case 2 disable case 2; design for Share CUP to other program

//Case 1 at 50F/S Maximum: 21000000 line/Sec;  Minimum: 17000000 Line/Sec;  400000 Line/Frame
//Case 2 at 50F/S Maximum: 700000 line/Sec;  Minimum: 500000 Line/Sec;  13000 Line/Frame

//const
//IO : array[0..1] of char = ('0','1');
var
  i:Integer;
  Frame_:integer;
  Line_:integer;
  Line_Frame:integer;

begin
  if Not Run_ then
  begin
    Run_:=True;
    Information.Previous:=0;
    Frame_:=0;
    Line_:=0;
    timer_.Clear;
    timer_.Start;


    while Run_ do
    begin
      Line_Frame:=0;
      application.ProcessMessages; //Work one program only   Case 1.

      //Run your program here

      Trect_.TopLeft.x:=1;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=PaintBox2.Width;
      Trect_.BottomRight.y:=PaintBox2.Height;
      Background_.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);

      Positioning:=Positioning+1;
      if Positioning = (bmp2.Width) then Positioning :=0;

      Trect_.TopLeft.x:=Positioning;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=Positioning+1;
      Trect_.BottomRight.y:=bmp2.Height;
      c := ColorToBGRA(rgb(255,50,0));
      Background_.PutImagePart(PaintBox2.Width-1,0,bmp2,Trect_,dmDrawWithTransparency);

      bmp.PutImage(0,0,Background_,dmDrawWithTransparency);

      for i:=0 to TotalBomb-1 do
      if Bomb[i].Life then
      begin
        bmp.PutImage(Bomb[i].Position.x,Bomb[i].Position.y,BitmapAnimation[Bomb[i].Bitmap_[Bomb[i].Actual_Frame]],dmDrawWithTransparency);
        Bomb[i].Remain_Speed:=Bomb[i].Remain_Speed-1;
        if Bomb[i].Remain_Speed<=0 then
        begin
          Bomb[i].Remain_Speed:=Bomb[i].Frame_Speed;
          Bomb[i].Actual_Frame:=Bomb[i].Actual_Frame+1;
          if Bomb[i].Actual_Frame>Bomb[i].TotalFrame-1 then
          begin
            Bomb[i].Actual_Frame:=0;
            Bomb[i].Position.x:=Random(PaintBox2.Width-(BitmapAnimation[Bomb[i].Bitmap_[0]].Width));
            Bomb[i].Position.y:=Random(PaintBox2.Height-BitmapAnimation[Bomb[i].Bitmap_[0]].Height);
            //Bomb[0].Life:=False;
          end;
        end;
      end;

      //Any text information here
      c := ColorToBGRA(rgb(0,105,208));
      bmp.FontHeight:=10;

      //bmp.TextOut(350,bmp.FontFullHeight*1,'Width/Height ='+IntToStr(Bomb[0].Bitmap_[0].Width)+'/'+IntToStr(Bomb[0].Bitmap_[0].Height),c);
      //bmp.TextOut(350,bmp.FontFullHeight*2,'Width div 2 /Height ='+IntToStr(Bomb[0].Bitmap_[0].Width div 2)+'/'+IntToStr(Bomb[0].Bitmap_[0].Height),c);
      Randomize;
      bmp.TextOut(350,bmp.FontFullHeight*3,'Random ='+FloatToStr(Random(10)*0.3),c);


      //Render here
      bmp.Draw(PaintBox2.Canvas,0,0,True);

      //Clear your hardware here

      while ((timer_.Elapsed -Information.Previous <= Information.Speed_frame) and
             (timer_.Elapsed < 1) and (Run_)) do //and (timer_.Elapsed < 1) do
      begin
        //application.ProcessMessages; //Share CPU  Case 2

        //Detect hardware here

        Line_:=Line_+1;
        Line_Frame:=Line_Frame+1;

        //Run_:=not Run_; //For run only 1 cycle
      end;

      //Other status here
      Information.TimePerFrame:=(timer_.Elapsed -Information.Previous)*1000;
      Information.Previous:=timer_.Elapsed;
      Frame_:=Frame_+1;
      if (Frame_ = 12) or (Frame_ = 24) or (Frame_ = 36) or (Frame_ = 48) then
      begin
        for i:=0 to TotalBomb-1 do if (not Bomb[i].Life) and (Random(9)=8) then Bomb[i].Life:=True;
      end;
      if timer_.Elapsed >= 1 then
      begin
        timer_.Stop;
        Information.ActualElapsed:=timer_.Elapsed*1000;
        Information.FramePerSec:=Frame_;
        Information.LineLeftover:=Line_;
        Information.LinePerFrame:=Line_Frame;

        Information.Previous:=0;
        Frame_:=0;
        Line_:=0;
        timer_.Clear;
        timer_.Start;
      end;

      //You can move your render to here. (!It is up to you)

    end;

    If not Run_ then  timer_.Stop;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, i2, i3:integer;

begin
  SetUpValue();

  Grid_.X:=26;
  Grid_.y:=15;

  if Grid_.X<0 then Grid_.X:=0;
  if Grid_.Y<0 then Grid_.Y:=0;

  Background_ := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00ffffff));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00CCCCCC));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp2 := TBGRABitmap.Create(Round(PaintBox2.Width/(Grid_.X+1))+1,PaintBox2.Height, ColorToBGRA($00CCCCCC));//ColorToBGRA($00CCCCCC)//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))

  Background_.Canvas2D.lineWidth:=1;
  Background_.Canvas2D.strokeStyle ('rgb(55,255,55)');
  Background_.Canvas2D.stroke();

  Background_.JoinStyle := pjsBevel;
  Background_.PenStyle := psSolid;

  c := ColorToBGRA(rgb(50,50,50));

  i2:=Round(PaintBox2.Width/(Grid_.X+1));
  i3:=0;
  for i := 0 to Grid_.X do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(i3,0), PointF(i3,PaintBox2.Height)],c,1);
  end;

  i2:=Round(PaintBox2.Height/(Grid_.Y+1));
  i3:=0;
  for i := 0 to Grid_.Y do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(0,i3), PointF(PaintBox2.Width,i3)],c,1);
  end;

  //c := ColorToBGRA(rgb(0,105,208));
  //Background_.DrawPolyLineAntialias([PointF(101+(0*20),10), PointF(101+(0*20),62)],c,1);
  //Background_.DrawPolyLineAntialias([PointF(121+(0*20),10), PointF(121+(0*20),62)],c,2);
  //Background_.Canvas2D.lineWidth:=1;
  //Background_.Canvas2D.strokeStyle ('rgb(0,0,0)');
  //Background_.Canvas2D.fillStyle(rgb(0,225,0));
  //Background_.Canvas2D.beginPath();
  //Background_.Canvas2D.moveTo(81,43);
  //Background_.Canvas2D.lineTo(81,52);
  //Background_.Canvas2D.lineTo(101,52);
  //Background_.Canvas2D.lineTo(101,43);
  //Background_.Canvas2D.closePath();
  //Background_.Canvas2D.fill();
  //Background_.Canvas2D.stroke();
  //Background_.TextOut(0,0,inttostr(round(timer_.Elapsed*1000))+ ' ms',BGRAWhite);
  //Background_.FillRect(0,70,20,90,BGRA(0,255,0,110), dmDrawWithTransparency);


  //bmp2.PutImage(5,2,Background_,dmDrawWithTransparency);
  //bmp2:=Background_.Resample(Grid_X*2, PaintBox2.Height) as TBGRABitmap; //stretch
  //Trect_.TopLeft.x:=5;
  //Trect_.TopLeft.y:=2;
  //Trect_.BottomRight.x:=15;//Grid_X*21;
  //Trect_.BottomRight.y:=PaintBox2.Height;
  //Background_.Draw(bmp2.Canvas,Trect_,True); //stretch
  //bmp2.Canvas2D.drawImage(bmp,5,2,15,PaintBox2.Height); //stretch

  //bmp.PutImage(0,0,Background_,dmDrawWithTransparency);

  Trect_.TopLeft.x:=0;
  Trect_.TopLeft.y:=0;
  Trect_.BottomRight.x:=bmp2.Width;
  Trect_.BottomRight.y:=bmp2.Height;
  bmp2.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);
  //bmp2.DrawPolyLineAntialias([PointF(0,0), PointF(0,bmp2.Height)],c,1);

  Positioning:=(PaintBox2.Width mod (Trect_.BottomRight.x-1));

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Main_Loop();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Information.Speed_frame:=0.02;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Information.Speed_frame:=0.029;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Run_:=False;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Information.Speed_frame:=0.1;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Run_:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  timer_.Free;
  Background_.Free;
  bmp.Free;
  bmp2.Free;
  for i:=0 to TotalBitmapAnimation-1 do  FreeAndNil(BitmapAnimation[i]);
end;


end.

