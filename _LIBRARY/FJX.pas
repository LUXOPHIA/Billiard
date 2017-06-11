unit FJX;

interface //######################################################################################## ■

uses System.Types, System.Math.Vectors, System.UITypes,
     FMX.Controls3D, FMX.Graphics;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TArray2<TValue_> = array of TArray<TValue_>;

     TArray3<TValue_> = array of TArray2<TValue_>;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HBitmapData

     HBitmapData = record helper for TBitmapData
     private
       ///// アクセス
       function GetColor( const X_,Y_:Integer ) :TAlphaColor; inline;
       procedure SetColor( const X_,Y_:Integer; const Color_:TAlphaColor ); inline;
     public
       ///// プロパティ
       property Color[ const X_,Y_:Integer ] :TAlphaColor read GetColor write SetColor;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRay3D

     TRay3D = record
     private
     public
       Pos :TVector3D;
       Vec :TVector3D;
       /////
       constructor Create( const Pos_,Vec_:TVector3D );
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HControl3D

     HControl3D = class Helper for TControl3D
     private
       ///// アクセス
       function Get_SizeX :Single; inline;
       procedure Set_SizeX( const _SizeX_:Single ); inline;
       function Get_SizeY :Single; inline;
       procedure Set_SizeY( const _SizeY_:Single ); inline;
       function Get_SizeZ :Single; inline;
       procedure Set_SizeZ( const _SizeZ_:Single ); inline;
     protected
       property _SizeX :Single read Get_SizeX write Set_SizeX;
       property _SizeY :Single read Get_SizeY write Set_SizeY;
       property _SizeZ :Single read Get_SizeZ write Set_SizeZ;
       ///// アクセス
       function GetAbsolMatrix :TMatrix3D; inline;
       procedure SetAbsolMatrix( const AbsoluteMatrix_:TMatrix3D ); virtual;
       function GetLocalMatrix :TMatrix3D; virtual;
       procedure SetLocalMatrix( const LocalMatrix_:TMatrix3D ); virtual;
       ///// メソッド
       procedure RecalcChildrenAbsolute;
       procedure RenderTree; inline;
     public
       ///// プロパティ
       property AbsolMatrix :TMatrix3D read GetAbsolMatrix write SetAbsolMatrix;
       property LocalMatrix :TMatrix3D read GetLocalMatrix write SetLocalMatrix;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TProxyObject

     TProxyObject = class( FMX.Controls3D.TProxyObject )
     private
     protected
       ///// メソッド
       procedure Render; override;
     public
     end;

const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

      Pi2 = 2 * Pi;
      Pi3 = 3 * Pi;
      Pi4 = 4 * Pi;

      P2i = Pi / 2;
      P3i = Pi / 3;
      P4i = Pi / 4;

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:Single ) :Single; inline; overload;
function Pow2( const X_:Double ) :Double; inline; overload;

function Roo2( const X_:Single ) :Single; inline; overload;
function Roo2( const X_:Double ) :Double; inline; overload;

function LimitRange( const O_,Min_,Max_:Single ) :Single; overload;
function LimitRange( const O_,Min_,Max_:Double ) :Double; overload;

implementation //################################################################################### ■

uses FMX.Types;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HBitmapData

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

function HBitmapData.GetColor( const X_,Y_:Integer ) :TAlphaColor;
begin
     Result := GetPixel( X_, Y_ );
end;

procedure HBitmapData.SetColor( const X_,Y_:Integer; const Color_:TAlphaColor );
begin
     SetPixel( X_, Y_, Color_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRay3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TRay3D.Create( const Pos_,Vec_:TVector3D );
begin
     Pos := Pos_;
     Vec := Vec_;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HControl3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////////////////////////// アクセス

function HControl3D.Get_SizeX :Single;
begin
     Result := FWidth;
end;

procedure HControl3D.Set_SizeX( const _SizeX_:Single );
begin
     FWidth := _SizeX_;
end;

function HControl3D.Get_SizeY :Single;
begin
     Result := FHeight;
end;

procedure HControl3D.Set_SizeY( const _SizeY_:Single );
begin
     FHeight := _SizeY_;
end;

function HControl3D.Get_SizeZ :Single;
begin
     Result := FDepth;
end;

procedure HControl3D.Set_SizeZ( const _SizeZ_:Single );
begin
     FDepth := _SizeZ_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////////////////////////// アクセス

function HControl3D.GetAbsolMatrix :TMatrix3D;
begin
     Result := AbsoluteMatrix;
end;

procedure HControl3D.SetAbsolMatrix( const AbsoluteMatrix_:TMatrix3D );
begin
     FAbsoluteMatrix := AbsoluteMatrix_;  FRecalcAbsolute := False;

     RecalcChildrenAbsolute;
end;

function HControl3D.GetLocalMatrix :TMatrix3D;
begin
     Result := FLocalMatrix;
end;

procedure HControl3D.SetLocalMatrix( const LocalMatrix_:TMatrix3D );
begin
     FLocalMatrix := LocalMatrix_;

     RecalcAbsolute;
end;

/////////////////////////////////////////////////////////////////////////////////////////// メソッド

procedure HControl3D.RecalcChildrenAbsolute;
var
   F :TFmxObject;
begin
     if Assigned( Children ) then
     begin
          for F in Children do
          begin
               if F is TControl3D then TControl3D( F ).RecalcAbsolute;
          end;
     end;
end;

procedure HControl3D.RenderTree;
begin
     RenderInternal;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TProxyObject

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////////////////////////// メソッド

procedure TProxyObject.Render;
var
   M :TMatrix3D;
   SX, SY, SZ :Single;
begin
     if Assigned( SourceObject ) then
     begin
          with SourceObject do
          begin
               M  := AbsoluteMatrix;
               SX := _SizeX;
               SY := _SizeY;
               SZ := _SizeZ;

               AbsolMatrix := Self.AbsoluteMatrix;
               _SizeX         := Self._SizeX;
               _SizeY         := Self._SizeY;
               _SizeZ         := Self._SizeZ;

               RenderTree;

               AbsolMatrix := M;
               _SizeX         := SX;
               _SizeY         := SY;
               _SizeZ         := SZ;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

function Pow2( const X_:Single ) :Single;
begin
     Result := Sqr( X_ );
end;

function Pow2( const X_:Double ) :Double;
begin
     Result := Sqr( X_ );
end;

////////////////////////////////////////////////////////////////////////////////////////////////////

function Roo2( const X_:Single ) :Single;
begin
     Result := Sqrt( X_ );
end;

function Roo2( const X_:Double ) :Double;
begin
     Result := Sqrt( X_ );
end;

////////////////////////////////////////////////////////////////////////////////////////////////////

function LimitRange( const O_,Min_,Max_:Single ) :Single;
begin
     if O_ < Min_ then Result := Min_
                  else
     if O_ > Max_ then Result := Max_
                  else Result := O_;
end;

function LimitRange( const O_,Min_,Max_:Double ) :Double;
begin
     if O_ < Min_ then Result := Min_
                  else
     if O_ > Max_ then Result := Max_
                  else Result := O_;
end;

//################################################################################################## □

initialization //############################################################################ 初期化

     Randomize;

finalization //############################################################################## 最終化

end. //############################################################################################# ■
