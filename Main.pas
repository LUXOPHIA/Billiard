unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Math.Vectors, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Viewport3D,
  FMX.Controls3D, FMX.Objects3D, FMX.MaterialSources,
  FJX,
  Core, FMX.Types3D;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    DummyY: TDummy;
    Camera1: TCamera;
    Light1: TLight;
    DummyX: TDummy;
    Timer1: TTimer;
    CubeG: TCube;
    LightMaterialSourceG: TLightMaterialSource;
    CubeL: TCube;
    CubeR: TCube;
    CubeT: TCube;
    CubeB: TCube;
    LightMaterialSourceW: TLightMaterialSource;
    DummyW: TDummy;
    LightMaterialSourceH: TLightMaterialSource;
    LightMaterialSourceB: TLightMaterialSource;
    Cylinder11: TCylinder;
    DummyH: TDummy;
    Cylinder10: TCylinder;
    Cylinder01: TCylinder;
    Cylinder00: TCylinder;
    DummyB: TDummy;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Timer1Timer(Sender: TObject);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
    /////
    procedure ClickBall( Sender_:TObject; Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single; RayPos_,RayDir_:TVector3D );
  public
    { public 宣言 }
    _Balls :TObjectList<TBall>;
    /////
    procedure MakeBalls( const Count_:Integer );
    function FindHit( const B0_:TBall; var MinD:Single ) :TControl3D;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

procedure TForm1.ClickBall( Sender_:TObject; Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single; RayPos_,RayDir_:TVector3D );
var
   V, N :TPoint3D;
begin
     V := Camera1.AbsoluteDirection.Normalize;
     N := TPoint3D.Create( 0, 1, 0 );

     TBall( Sender_ ).Velo0 := V - V.DotProduct( N ) * N;  //カメラの向いている方向へ打つ
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

procedure TForm1.MakeBalls( const Count_:Integer );
var
   I :Integer;
   B :TBall;
begin
     _Balls.Clear;

     for I := 1 to Count_ do
     begin
          B := TBall.Create( Self );

          with B do
          begin
               Parent         := DummyB;
               MaterialSource := LightMaterialSourceB;

               OnMouseDown := ClickBall;
          end;

          _Balls.Add( B );
     end;
end;

function TForm1.FindHit( const B0_:TBall; var MinD:Single ) :TControl3D;
//---------------------------------------------------------------------
     procedure MinOK( const T_:Single; const H_:TControl3D );
     begin
          if T_ < MinD then
          begin
               MinD := T_;  Result := H_;
          end;
     end;
//---------------------------------------------------------------------
var
   P0, P1 :TPoint3D;
   B1 :TBall;
begin
     P0 := TPoint3D( B0_.AbsolutePosition );

     MinD := 0;

     Result := nil;

     ///// 壁との衝突判定

     MinOK( P0.X - -25 - 2, CubeL );
     MinOK( +25 - P0.X - 2, CubeR );
     MinOK( P0.Z - -50 - 2, CubeB );
     MinOK( +50 - P0.Z - 2, CubeT );

     ///// 穴との衝突判定

     MinOK( P0.Distance( TPoint3D.Create( -25, -2, -50 ) ) - 4, Cylinder00 );
     MinOK( P0.Distance( TPoint3D.Create( +25, -2, -50 ) ) - 4, Cylinder01 );
     MinOK( P0.Distance( TPoint3D.Create( -25, -2, +50 ) ) - 4, Cylinder10 );
     MinOK( P0.Distance( TPoint3D.Create( +25, -2, +50 ) ) - 4, Cylinder11 );

     ///// 玉との衝突判定

     for B1 in _Balls do
     begin
          if B1 <> B0_ then
          begin
               P1 := TPoint3D( B1.AbsolutePosition );

               MinOK( P0.Distance( P1 ) - 4, B1 );
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Balls := TObjectList<TBall>.Create;

     MakeBalls( 10 );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Balls.Free;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;

     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with DummyY.RotationAngle do Y := Y + ( P.X - _MouseP.X ) / 2;
          with DummyX.RotationAngle do X := X - ( P.Y - _MouseP.Y ) / 2;

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Timer1Timer(Sender: TObject);
var
   B0, B1 :TBall;
   H :TControl3D;
   T, R, E, S0 :Single;
   P0, P1, N, V, D0, A :TPoint3D;
   M :TMatrix3D;
begin
     for B0 in _Balls do
     begin
          H := FindHit( B0, T );

          with B0 do
          begin
               if H is TCube then
               begin
                    ///// 壁に衝突

                    E := Bounce * _WallBounce;

                    if H = CubeL then N := TPoint3D.Create( +1, 0, 0 )
                                 else
                    if H = CubeR then N := TPoint3D.Create( -1, 0, 0 )
                                 else
                    if H = CubeB then N := TPoint3D.Create( 0, 0, +1 )
                                 else
                    if H = CubeT then N := TPoint3D.Create( 0, 0, -1 );

                    Velo1 := Velo0 - ( _Penalty * T + ( 1 + E ) * Velo0.DotProduct( N ) ) * N;
               end
               else
               if H is TCylinder then
               begin
                    ///// 穴に衝突

                    _Balls.Remove( B0 );
               end
               else
               if H is TBall then
               begin
                    ///// 玉に衝突

                    B1 := TBall( H );

                    R := B1.Mass / ( Mass + B1.Mass );

                    E := Bounce * B1.Bounce;

                    V := Velo0 - B1.Velo0;

                    P0 := TPoint3D(    AbsolutePosition );
                    P1 := TPoint3D( B1.AbsolutePosition );

                    N := ( P0 - P1 ).Normalize;

                    Velo1 := Velo0 - ( _Penalty * T + R * ( 1 + E ) * V.DotProduct( N ) ) * N;
               end
               else Velo1 := Velo0;
          end;
     end;

     for B0 in _Balls do
     begin
          with B0 do
          begin
               Velo0 := Velo1;

               P0 := TPoint3D( AbsolutePosition );
               D0 := Velo0.Normalize;
               S0 := Velo0.Length;

               M := TMatrix3D.CreateTranslation( P0 );
               A := D0.CrossProduct( TPoint3D.Create( 0, 1, 0 ) );

               AbsolMatrix := AbsolMatrix
                            * M.Inverse
                            * TMatrix3D.CreateRotation( A, S0 / Pi4 * Pi2 )
                            * M
                            * TMatrix3D.CreateTranslation( Velo0 );
          end;
     end;

     Viewport3D1.Repaint;
end;

end.
