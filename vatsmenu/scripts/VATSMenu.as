package
{
   import Shared.AS3.BSButtonHintBar;
   import Shared.AS3.BSButtonHintData;
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Data.FromClientDataEvent;
   import Shared.AS3.IMenu;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.StageAlign;
   import flash.events.*;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.net.*;
   import flash.system.*;
   import flash.text.TextFieldAutoSize;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol91")]
   public class VATSMenu extends IMenu
   {
       
      
      private const MAX_NEAREST_PARTS:uint = 4;
      
      private const RESISTANCE_ENTRY_SPACING:Number = 14;
      
      private const STAGE_WIDTH:uint = 1280;
      
      private const STAGE_HEIGHT:uint = 720;
      
      private const STAGE_RATIO:Number = 1.7777777777777777;
      
      private const ALIGNMENT_OFFSET:Number = 7;
      
      public var PartSelectDistanceWeight:Number = 0.3;
      
      public var BGSCodeObj:Object;
      
      public var ButtonHintInstance:BSButtonHintBar;
      
      public var ApplyCriticalInstance:MovieClip;
      
      public var FourLeafInstance:MovieClip;
      
      public var ResistancesInstance:MovieClip;
      
      public var ResistanceBracketsInstance:MovieClip;
      
      public var BossIcon_mc:MovieClip;
      
      public var PartInfos:Array;
      
      public var SelectedPart:uint;
      
      public var ResistanceData:Array;
      
      private var ButtonDataA:Vector.<BSButtonHintData>;
      
      private var CancelButton:BSButtonHintData;
      
      private var BodyPartButton:BSButtonHintData;
      
      private var CycleTargetsButton:BSButtonHintData;
      
      private var ExecuteCriticalButton:BSButtonHintData;
      
      private var CancelPlaybackButton:BSButtonHintData;
      
      private var bShowPlaybackButtons:Boolean = false;
      
      private var bShowButtonHelp:Boolean = true;
      
      private var bCriticalsEnabled:Boolean = true;
      
      private var m_ScreenRatio:Number = 1;
      
      private var modLoader:Loader;
      
      public function VATSMenu()
      {
         this.PartSelectDistanceWeight = 0.3;
         this.ResistanceData = new Array();
         this.CancelButton = new BSButtonHintData("$RETURN","Tab","PSN_B","Xenon_B",1,this.onCancelButtonClick);
         this.BodyPartButton = new BSButtonHintData("$PART","Mousewheel","PSN_RS","Xenon_RS",1,this.onBodyPartButtonClick);
         this.CycleTargetsButton = new BSButtonHintData("$TARGET","Z","_DPad_LR","_DPad_LR",1,this.onCycleTargetButtonClick);
         this.ExecuteCriticalButton = new BSButtonHintData("$CRITICAL","Space","PSN_Y","Xenon_Y",1,this.onExecuteCriticalButtonClick);
         this.CancelPlaybackButton = new BSButtonHintData("$ABORT","Tab","PSN_B","Xenon_B",1,this.onCancelPlaybackButtonClick);
         super();
         stage.align = StageAlign.TOP_LEFT;
         this.BGSCodeObj = new Object();
         this.PartInfos = new Array();
         this.SelectedPart = uint.MAX_VALUE;
         this.SetResistancesVisible(false);
         this.ApplyCriticalInstance.stop();
         this.ApplyCriticalInstance.visible = false;
         this.x = 0;
         this.y = 0;
         this.CycleTargetsButton.SetSecondaryButtons("C","","");
         this.UpdateButtonVisibility();
         this.ButtonDataA = new Vector.<BSButtonHintData>();
         this.ButtonDataA.push(this.CancelButton);
         this.ButtonDataA.push(this.BodyPartButton);
         this.ButtonDataA.push(this.CycleTargetsButton);
         this.ButtonDataA.push(this.ExecuteCriticalButton);
         this.ButtonDataA.push(this.CancelPlaybackButton);
         this.ButtonHintInstance.SetButtonHintData(this.ButtonDataA);
         BSUIDataManager.Subscribe("ScreenResolutionData",this.onScreenDataUpdate);
         this.loadMod("VatsPriority.swf");
      }
      
      private function loadMod(param1:String) : void
      {
         try
         {
            modLoader = new Loader();
            modLoader.load(new URLRequest(param1),new LoaderContext(false,ApplicationDomain.currentDomain));
            addChild(modLoader);
         }
         catch(e:Error)
         {
         }
      }
      
      private function onScreenDataUpdate(param1:FromClientDataEvent) : void
      {
         if(param1.data && param1.data.AspectRatio != "16:9" || param1.data && param1.data.AspectRatio != "16:10")
         {
            this.m_ScreenRatio = param1.data.ScreenWidth / param1.data.ScreenHeight;
         }
         else
         {
            this.m_ScreenRatio = 1;
         }
      }
      
      private function onCancelButtonClick() : *
      {
         this.BGSCodeObj.onCancel();
      }
      
      private function onBodyPartButtonClick() : *
      {
         this.BGSCodeObj.CycleBodyPart();
      }
      
      private function onCycleTargetButtonClick() : *
      {
         this.BGSCodeObj.CycleTarget();
      }
      
      private function onExecuteCriticalButtonClick() : *
      {
         this.BGSCodeObj.ExecuteCritical();
      }
      
      private function onCancelPlaybackButtonClick() : *
      {
         this.BGSCodeObj.CancelPlayback();
      }
      
      public function SetSelectedPart(param1:uint) : *
      {
         this.SelectedPart = param1;
      }
      
      public function UpdatePartPositions(param1:Array) : *
      {
         var _loc4_:Number = NaN;
         var _loc9_:Point = null;
         var _loc10_:uint = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Point = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc2_:uint = 0;
         while(_loc2_ < param1.length && _loc2_ < this.PartInfos.length)
         {
            if(param1[_loc2_].x != undefined && param1[_loc2_].x > 0)
            {
               this.PartInfos[_loc2_].visible = param1[_loc2_].visible != null ? param1[_loc2_].visible : true;
               this.PartInfos[_loc2_].x = (0.5 + (param1[_loc2_].x - 0.5) * (this.m_ScreenRatio / this.STAGE_RATIO)) * this.STAGE_WIDTH;
               this.PartInfos[_loc2_].y = param1[_loc2_].y * this.STAGE_HEIGHT;
            }
            else
            {
               this.PartInfos[_loc2_].visible = false;
            }
            _loc2_++;
         }
         var _loc3_:uint = 2;
         _loc4_ = 80;
         var _loc5_:Number = _loc4_ * _loc4_;
         var _loc6_:Number = 50;
         var _loc7_:Array = new Array();
         _loc2_ = 0;
         while(_loc2_ < this.PartInfos.length)
         {
            _loc7_[_loc2_] = new Point(0,0);
            _loc2_++;
         }
         var _loc8_:uint = 0;
         while(_loc8_ < _loc3_)
         {
            _loc2_ = 1;
            while(_loc2_ < this.PartInfos.length)
            {
               if(this.PartInfos[_loc2_].visible)
               {
                  _loc9_ = new Point(this.PartInfos[_loc2_].x + _loc7_[_loc2_].x,this.PartInfos[_loc2_].y + _loc7_[_loc2_].y);
                  _loc10_ = 0;
                  while(_loc10_ < this.PartInfos.length)
                  {
                     if(_loc2_ != _loc10_ && Boolean(this.PartInfos[_loc10_].visible))
                     {
                        _loc11_ = this.PartInfos[_loc10_].x - _loc9_.x;
                        _loc12_ = this.PartInfos[_loc10_].y - _loc9_.y;
                        if((_loc13_ = _loc11_ * _loc11_ + _loc12_ * _loc12_) < _loc5_)
                        {
                           _loc15_ = (_loc14_ = new Point(_loc9_.x - this.PartInfos[_loc10_].x,_loc9_.y - this.PartInfos[_loc10_].y)).length;
                           _loc16_ = Math.max(0,_loc4_ - _loc15_);
                           if(_loc15_ > 0)
                           {
                              _loc17_ = _loc16_ / _loc15_;
                              _loc14_.x *= _loc17_;
                              _loc14_.y *= _loc17_;
                              _loc7_[_loc2_].x += _loc14_.x;
                              _loc7_[_loc2_].y += _loc14_.y;
                           }
                        }
                     }
                     _loc10_++;
                  }
               }
               _loc2_++;
            }
            _loc8_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.PartInfos.length)
         {
            if((_loc18_ = Number(_loc7_[_loc2_].length)) > _loc6_ && _loc18_ > 0)
            {
               _loc18_ = _loc6_ / _loc18_;
               _loc7_[_loc2_].x *= _loc18_;
               _loc7_[_loc2_].y *= _loc18_;
            }
            this.PartInfos[_loc2_].x += _loc7_[_loc2_].x;
            this.PartInfos[_loc2_].y += _loc7_[_loc2_].y;
            _loc2_++;
         }
      }
      
      public function FindNearestParts(param1:Vector.<uint>, param2:uint, param3:Vector3D, param4:Number) : *
      {
         var selectedPart:PartInfo = null;
         var selectedPartPos:Vector3D = null;
         var comparisonIndices:Vector.<uint> = null;
         var comparisonValues:Vector.<Number> = null;
         var inputPerp:Vector3D = null;
         var angleThresholdRad:* = undefined;
         var partIndex:uint = 0;
         var i:uint = 0;
         var partVec:Vector3D = null;
         var aNearestParts:Vector.<uint> = param1;
         var auiSelectedPart:uint = param2;
         var aInput:Vector3D = param3;
         var aAngleThresholdDeg:Number = param4;
         aNearestParts.length = 0;
         if(auiSelectedPart < this.PartInfos.length)
         {
            selectedPart = this.PartInfos[auiSelectedPart];
            selectedPartPos = new Vector3D(selectedPart.x,selectedPart.y);
            comparisonIndices = new Vector.<uint>(this.PartInfos.length,true);
            comparisonValues = new Vector.<Number>(this.PartInfos.length,true);
            inputPerp = new Vector3D(-aInput.y,aInput.x);
            angleThresholdRad = aAngleThresholdDeg * Math.PI / 180;
            partIndex = 0;
            while(partIndex < this.PartInfos.length)
            {
               comparisonIndices[partIndex] = partIndex;
               if(partIndex == auiSelectedPart)
               {
                  comparisonValues[partIndex] = -1;
               }
               else
               {
                  partVec = new Vector3D(this.PartInfos[partIndex].x,this.PartInfos[partIndex].y);
                  partVec.decrementBy(selectedPartPos);
                  comparisonValues[partIndex] = Vector3D.angleBetween(aInput,partVec) <= angleThresholdRad ? this.PartSelectDistanceWeight * Math.abs(aInput.dotProduct(partVec)) + Math.abs(inputPerp.dotProduct(partVec)) : -1;
               }
               partIndex++;
            }
            comparisonIndices.sort(function(param1:uint, param2:uint):*
            {
               var _loc3_:int = 0;
               if(comparisonValues[param1] < comparisonValues[param2])
               {
                  _loc3_ = -1;
               }
               else if(comparisonValues[param1] > comparisonValues[param2])
               {
                  _loc3_ = 1;
               }
               return _loc3_;
            });
            i = 0;
            while(i < comparisonIndices.length && aNearestParts.length < this.MAX_NEAREST_PARTS)
            {
               if(comparisonValues[comparisonIndices[i]] >= 0)
               {
                  aNearestParts.push(comparisonIndices[i]);
               }
               i++;
            }
         }
      }
      
      public function ProcessPartSelectionInput(param1:Number, param2:Number, param3:Number) : *
      {
         var _loc4_:Vector3D;
         (_loc4_ = new Vector3D(param1,-param2)).normalize();
         var _loc5_:Vector.<uint> = new Vector.<uint>();
         this.FindNearestParts(_loc5_,this.SelectedPart,_loc4_,param3);
         if(_loc5_.length > 0)
         {
            this.BGSCodeObj.SelectPart(_loc5_[0]);
         }
      }
      
      public function SetPartChanceToHit(param1:uint, param2:uint) : *
      {
         if(param1 < this.PartInfos.length)
         {
            this.PartInfos[param1].SetChanceToHit(param2);
         }
      }
      
      public function RefreshActionDisplay(param1:Array) : *
      {
         var _loc2_:uint = 0;
         var _loc3_:Vector.<uint> = new Vector.<uint>(this.PartInfos.length);
         var _loc4_:uint = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_[param1[_loc4_]] += 1;
            if(_loc3_[param1[_loc4_]] >= _loc3_[_loc2_])
            {
               _loc2_ = uint(param1[_loc4_]);
            }
            _loc4_++;
         }
         var _loc5_:uint = 0;
         while(_loc5_ < this.PartInfos.length)
         {
            this.PartInfos[_loc5_].SetActionCount(_loc3_[_loc5_]);
            _loc5_++;
         }
         if(this.getChildAt(this.numChildren - 1) != this.PartInfos[_loc2_])
         {
            this.swapChildren(this.getChildAt(this.numChildren - 1),this.PartInfos[_loc2_]);
         }
         stage.dispatchEvent(new Event("VatsPriority::RefreshActionDisplay"));
      }
      
      public function ShowPlaybackButtons() : *
      {
         this.SetResistancesVisible(false);
         this.bShowPlaybackButtons = true;
         this.UpdateButtonVisibility();
         this.DisableCriticalButton();
      }
      
      public function UpdateButtonVisibility() : *
      {
         this.CancelButton.ButtonVisible = this.bShowButtonHelp && !this.bShowPlaybackButtons;
         this.BodyPartButton.ButtonVisible = this.bShowButtonHelp && !this.bShowPlaybackButtons && this.PartInfos.length > 1;
         this.CycleTargetsButton.ButtonVisible = this.bShowButtonHelp && !this.bShowPlaybackButtons;
         this.ExecuteCriticalButton.ButtonVisible = this.bShowButtonHelp && !this.bShowPlaybackButtons && this.bCriticalsEnabled;
         this.CancelPlaybackButton.ButtonVisible = this.bShowButtonHelp && this.bShowPlaybackButtons;
      }
      
      public function HideButtonHelp() : *
      {
         this.SetResistancesVisible(false);
         this.bShowButtonHelp = false;
         this.UpdateButtonVisibility();
      }
      
      public function ShowButtonHelp() : *
      {
         this.SetResistancesVisible(this.ResistanceData.length > 0);
         this.bShowButtonHelp = true;
         this.UpdateButtonVisibility();
      }
      
      public function EnableCriticalButton() : *
      {
         this.ExecuteCriticalButton.ButtonDisabled = false;
         this.ExecuteCriticalButton.ButtonFlashing = true;
      }
      
      public function DisableCriticalButton() : *
      {
         this.ExecuteCriticalButton.ButtonFlashing = false;
         this.ExecuteCriticalButton.ButtonDisabled = true;
      }
      
      public function HideCriticalButton() : *
      {
         this.bCriticalsEnabled = false;
         this.UpdateButtonVisibility();
      }
      
      public function ApplyCritical() : *
      {
         this.ApplyCriticalInstance.visible = true;
         this.ApplyCriticalInstance.gotoAndPlay("Show");
         this.FourLeafInstance.visible = false;
      }
      
      public function DisableAbortButton() : *
      {
         this.CancelPlaybackButton.ButtonDisabled = true;
      }
      
      public function ShowFourLeafClip() : *
      {
         this.FourLeafInstance.visible = true;
         this.FourLeafInstance.gotoAndPlay("Show");
         this.ApplyCriticalInstance.visible = false;
      }
      
      public function SetResistancesVisible(param1:Boolean) : *
      {
         this.ResistancesInstance.visible = param1;
         this.ResistanceBracketsInstance.visible = param1;
      }
      
      public function UpdateTargetInfo() : *
      {
         var _loc3_:ResistanceEntry = null;
         var _loc4_:Number = NaN;
         var _loc1_:uint = uint(this.ResistancesInstance.Container.numChildren);
         while(_loc1_ < this.ResistanceData.length)
         {
            this.ResistancesInstance.Container.addChild(new ResistanceEntry());
            _loc1_++;
         }
         this.ResistancesInstance.BackgroundInstance.width = 0;
         var _loc2_:Number = 0;
         _loc1_ = 0;
         while(_loc1_ < this.ResistancesInstance.Container.numChildren)
         {
            _loc3_ = this.ResistancesInstance.Container.getChildAt(_loc1_) as ResistanceEntry;
            _loc3_.visible = _loc1_ < this.ResistanceData.length;
            _loc4_ = _loc3_.visible ? 1 : 0;
            _loc3_.scaleX = _loc4_;
            _loc3_.scaleY = _loc4_;
            _loc3_.x = _loc2_;
            _loc3_.y = 0;
            _loc3_.ResistanceValue.autoSize = TextFieldAutoSize.LEFT;
            if(_loc3_.visible)
            {
               _loc3_.ResistanceIcon.gotoAndStop(this.ResistanceData[_loc1_].damageType);
               if(this.ResistanceData[_loc1_].bImmune)
               {
                  _loc3_.ResistanceValue.visible = false;
                  _loc3_.ResistanceValue.text = "";
                  _loc3_.ImmunityIcon.visible = true;
               }
               else
               {
                  _loc3_.ResistanceValue.visible = true;
                  _loc3_.ResistanceValue.text = this.ResistanceData[_loc1_].text;
                  _loc3_.ImmunityIcon.visible = false;
               }
               _loc2_ += _loc3_.width + this.RESISTANCE_ENTRY_SPACING;
            }
            _loc1_++;
         }
         this.ResistancesInstance.BackgroundInstance.width = this.ResistanceData.length > 0 ? this.ResistancesInstance.width + this.RESISTANCE_ENTRY_SPACING : 0;
         this.ResistancesInstance.x = this.STAGE_WIDTH / 2 - this.ResistancesInstance.width / 2;
         this.ResistanceBracketsInstance.width = this.ResistancesInstance.width;
         this.UpdateButtonVisibility();
         stage.dispatchEvent(new Event("VatsPriority::UpdateTargetInfo"));
      }
      
      public function SetTargetLevel(param1:uint, param2:uint, param3:Boolean) : *
      {
         var _loc4_:Rectangle = null;
         if(param2 > 0)
         {
            this.ResistancesInstance.gotoAndStop("Skull");
            this.ResistancesInstance.Skull.gotoAndStop(param2);
            this.ResistancesInstance.BossIcon_mc.visible = param3;
            this.ResistancesInstance.Level.text = "";
            _loc4_ = this.ResistancesInstance.Skull.getBounds(this.ResistancesInstance);
            this.ResistancesInstance.BossIcon_mc.x = _loc4_.x + _loc4_.width / 2 - this.ResistancesInstance.BossIcon_mc.width / 2 + this.ALIGNMENT_OFFSET;
         }
         else
         {
            this.ResistancesInstance.gotoAndStop("Level");
            this.ResistancesInstance.Level.text = param1;
         }
      }
   }
}
