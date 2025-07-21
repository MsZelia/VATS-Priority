package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class VatsPriority extends MovieClip
   {
      
      public static const MOD_NAME:String = "VATSPriority";
      
      public static const MOD_VERSION:String = "1.0.2";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../VATSPriorityConfig.json";
      
      public static const HUD_TOOLS_SENDER_NAME:String = MOD_NAME + "_HUD";
      
      public static const EVENT_VATS_PRIORITY_REFRESH:String = "VatsPriority::RefreshActionDisplay";
      
      public static const EVENT_VATS_PRIORITY_UPDATE_TARGET:String = "VatsPriority::UpdateTargetInfo";
      
      public static var DEBUG:int = 0;
      
      public static var DISABLED:Boolean = false;
      
      private static const HUDTOOLS_MENU_ENABLE:String = MOD_NAME + "_ENABLE";
      
      private static const HUDTOOLS_MENU_DISABLE:String = MOD_NAME + "_DISABLE";
       
      
      private var topLevel:*;
      
      private var debug_tf:TextField;
      
      private var lastConfig:String;
      
      private var config:Object;
      
      private var isHUDMenu:Boolean = false;
      
      private var hudTools:SharedHUDTools;
      
      private var targetName:String = "";
      
      private var refreshTargetTimer:Timer;
      
      private var lockTargetTimer:Timer;
      
      public function VatsPriority()
      {
         super();
         this.createDebugTf();
         this.loadConfig();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      public static function indexOfCaseInsensitiveString(arr:Array, searchingFor:String, fromIndex:uint = 0) : int
      {
         var uppercaseSearchString:String = searchingFor.toUpperCase();
         var arrayLength:uint = arr.length;
         var index:uint = fromIndex;
         while(index < arrayLength)
         {
            var element:* = arr[index];
            if(element is String && uppercaseSearchString.indexOf(element.toUpperCase()) != -1)
            {
               return index;
            }
            index++;
         }
         return -1;
      }
      
      private function createDebugTf() : void
      {
         this.debug_tf = new TextField();
         this.debug_tf.x = 20;
         this.debug_tf.y = 20;
         this.debug_tf.width = 700;
         this.debug_tf.height = 660;
         GlobalFunc.SetText(this.debug_tf,"",false);
         this.debug_tf.wordWrap = true;
         this.debug_tf.multiline = true;
         var font:TextFormat = new TextFormat("$MAIN_Font",12,16777215);
         this.debug_tf.defaultTextFormat = font;
         this.debug_tf.setTextFormat(font);
         this.debug_tf.selectable = true;
         this.debug_tf.mouseWheelEnabled = true;
         this.debug_tf.mouseEnabled = true;
         this.debug_tf.visible = false;
         addChild(this.debug_tf);
      }
      
      public function displayMessage(param1:*, debugLevel:int = 1, clear:Boolean = false) : void
      {
         if(DEBUG < debugLevel)
         {
            return;
         }
         if(clear)
         {
            this.debug_tf.text = "";
         }
         if(param1 is String)
         {
            var str:String = param1;
         }
         else
         {
            str = toString(param1);
         }
         this.debug_tf.text = this.debug_tf.text.substr(-4096) + "\n" + str;
         this.debug_tf.visible = true;
         this.debug_tf.scrollV = this.debug_tf.maxScrollV;
      }
      
      private function loadConfig() : void
      {
         var loaderComplete:Function;
         var ioErrorHandler:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            loaderComplete = function(param1:Event):void
            {
               var _alt:*;
               try
               {
                  config = new JSONDecoder(loader.data,true).getValue();
                  DEBUG = isHUDMenu ? -1 : config.debug;
                  DISABLED = Boolean(config.disabled);
                  config.defaultPriority = config.defaultPriority != null ? config.defaultPriority.toUpperCase() : "HEAD";
                  config.lockPriorityTarget = Boolean(config.lockPriorityTarget);
                  config.lockPriorityTargetExcluded = [].concat(config.lockPriorityTargetExcluded);
                  config.useTargetNames = Boolean(config.useTargetNames);
                  if(config.priorities == null)
                  {
                     config.priorities = {};
                  }
                  for(prioTarget in config.priorities)
                  {
                     if(config.priorities[prioTarget] != null)
                     {
                        config.priorities[prioTarget] = [].concat(config.priorities[prioTarget]);
                        for(alt in config.priorities[prioTarget])
                        {
                           _alt = config.priorities[prioTarget][alt];
                           if(_alt is String)
                           {
                              config.priorities[prioTarget][alt] = {
                                 "partName":_alt.toUpperCase(),
                                 "minHitChance":-1,
                                 "notCrippled":false
                              };
                           }
                           else if(_alt is Object)
                           {
                              config.priorities[prioTarget][alt].partName = Boolean(_alt.partName) ? _alt.partName.toUpperCase() : config.defaultPriority;
                              config.priorities[prioTarget][alt].minHitChance = _alt.minHitChance != null && !isNaN(_alt.minHitChance) ? _alt.minHitChance : -1;
                              config.priorities[prioTarget][alt].notCrippled = Boolean(_alt.notCrippled);
                           }
                        }
                     }
                  }
                  displayMessage(FULL_MOD_NAME + " | Config file loaded!",1);
                  displayMessage(toString(config),2);
                  setPriority();
               }
               catch(e:Error)
               {
                  displayMessage(FULL_MOD_NAME + " | Error parsing config: " + e,0);
               }
               loader.removeEventListener(Event.COMPLETE,loaderComplete);
            };
            ioErrorHandler = function(param1:Event):void
            {
               displayMessage(FULL_MOD_NAME + " | Error loading config :: " + param1.text,0);
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete,false,0,true);
            loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
         }
         catch(e:Error)
         {
            displayMessage(FULL_MOD_NAME + " | Error loading config: " + e,0);
         }
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == "HUDMenu")
            {
               DEBUG = -1;
               this.isHUDMenu = true;
               this.hudTools = new SharedHUDTools(HUD_TOOLS_SENDER_NAME);
               this.hudTools.FormatMenu(50,-100);
               this.hudTools.RegisterMenu(this.onBuildMenu,this.onSelectMenu);
               this.initTargetRefreshTimer();
               BSUIDataManager.Subscribe("HUDModeData",this.onHUDModeUpdate);
               trace(MOD_NAME + " added to HUDMenu");
            }
            else if(this.topLevel.numChildren > 0)
            {
               this.topLevel = this.topLevel.getChildAt(0);
               if(Boolean(this.topLevel) && getQualifiedClassName(this.topLevel) == "VATSMenu")
               {
                  this.hudTools = new SharedHUDTools(MOD_NAME);
                  this.hudTools.Register(this.onReceiveMessage);
                  this.initTargetLockTimer();
                  stage.addEventListener(EVENT_VATS_PRIORITY_REFRESH,this.onRefreshActionDisplay,false,0,true);
                  stage.addEventListener(EVENT_VATS_PRIORITY_UPDATE_TARGET,this.onTargetChanged,false,0,true);
                  trace(MOD_NAME + " added to VATSMenu");
               }
               else
               {
                  trace(MOD_NAME + " not added to VATSMenu");
                  displayMessage(MOD_NAME + " not added to VATSMenu",0);
               }
            }
         }
         else
         {
            trace(MOD_NAME + " not added to stage");
            displayMessage(MOD_NAME + " not added to stage",0);
         }
      }
      
      public function removedFromStageHandler(param1:Event) : *
      {
         if(stage)
         {
            stage.removeEventListener(EVENT_VATS_PRIORITY_REFRESH,this.onRefreshActionDisplay);
            stage.removeEventListener(EVENT_VATS_PRIORITY_UPDATE_TARGET,this.onTargetChanged);
         }
         if(this.refreshTargetTimer)
         {
            this.refreshTargetTimer.removeEventListener(TimerEvent.TIMER,this.updateTargetName);
         }
         if(this.lockTargetTimer)
         {
            this.lockTargetTimer.removeEventListener(TimerEvent.TIMER,this.onLockTargetUpdate);
         }
         if(this.hudtools)
         {
            this.hudtools.Shutdown();
         }
      }
      
      public function onBuildMenu(parentItem:String = null) : *
      {
         try
         {
            if(parentItem == HUD_TOOLS_SENDER_NAME)
            {
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_ENABLE,"Enable",true,false,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_DISABLE,"Disable",true,false,250);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSelectMenu(selectItem:String) : *
      {
         if(selectItem == HUDTOOLS_MENU_DISABLE)
         {
            DISABLED = true;
         }
         else if(selectItem == HUDTOOLS_MENU_ENABLE)
         {
            DISABLED = false;
         }
      }
      
      private function initTargetRefreshTimer() : void
      {
         this.refreshTargetTimer = new Timer(50);
         this.refreshTargetTimer.addEventListener(TimerEvent.TIMER,this.updateTargetName,false,0,true);
      }
      
      private function initTargetLockTimer() : void
      {
         this.lockTargetTimer = new Timer(50);
         this.lockTargetTimer.addEventListener(TimerEvent.TIMER,this.onLockTargetUpdate,false,0,true);
         this.lockTargetTimer.start();
      }
      
      private function onLockTargetUpdate() : void
      {
         if(!isTargetLocked())
         {
            return;
         }
         this.setPriority(false);
      }
      
      private function updateTargetName() : void
      {
         var newTargetName:String;
         try
         {
            newTargetName = this.topLevel.TopCenterGroup_mc.EnemyHealthMeter_mc.DisplayText_mc.DisplayText_tf.text.toUpperCase();
            if(newTargetName != this.targetName)
            {
               this.targetName = newTargetName;
               displayMessage("Sending message: " + this.targetName,2);
               this.hudTools.SendMessage(MOD_NAME,this.targetName);
            }
         }
         catch(e:*)
         {
            displayMessage("Error updating TargetName: " + e,0);
         }
      }
      
      private function onHUDModeUpdate(event:*) : void
      {
         try
         {
            if(event == null || event.data == null)
            {
               return;
            }
            if(this.isHUDMenu)
            {
               if(event.data.hudMode == HUDModes.VATS_MODE)
               {
                  if(DISABLED)
                  {
                     this.hudTools.SendMessage(MOD_NAME,HUDTOOLS_MENU_DISABLE);
                  }
                  else
                  {
                     this.refreshTargetTimer.start();
                  }
               }
               else
               {
                  this.refreshTargetTimer.reset();
                  this.targetName = "";
                  if(config && config.showModMenu)
                  {
                     this.hudTools.CloseMenu();
                  }
               }
               if(config && config.showModMenu && event.data.hudMode == HUDModes.PIPBOY)
               {
                  this.hudTools.ShowMenu();
               }
            }
         }
         catch(e:Error)
         {
            displayMessage("Error updating HUDMode: " + e,0);
         }
      }
      
      public function onReceiveMessage(sender:String, msg:String) : void
      {
         try
         {
            displayMessage("Received message from " + sender + ": " + msg,2);
            if(sender == HUD_TOOLS_SENDER_NAME)
            {
               if(msg == HUDTOOLS_MENU_DISABLE)
               {
                  displayMessage("Mod disabled!",1);
               }
               else
               {
                  this.targetName = msg.toUpperCase();
                  displayMessage("Target name set to: \"" + this.targetName + "\"",1);
                  setTimeout(this.setPriority,20);
               }
            }
         }
         catch(e:Error)
         {
            displayMessage("onReceiveMessage error (" + sender + ":" + msg + "): " + e,0);
         }
      }
      
      public function onRefreshActionDisplay(event:Event) : void
      {
         if(!isTargetLocked())
         {
            return;
         }
         displayMessage("RefreshActionDisplay",2);
         setTimeout(this.setPriority,20,false);
      }
      
      public function onTargetChanged(event:Event) : void
      {
         if(!config)
         {
            return;
         }
         displayMessage("TargetChanged",2);
         setTimeout(this.setPriority,20);
      }
      
      public function setPriority(logMsg:Boolean = true) : void
      {
         if(DISABLED || !this.topLevel || !this.topLevel.PartInfos || this.topLevel.PartInfos.length == 0)
         {
            return;
         }
         if(!config || config.disabled || config.useTargetNames && this.targetName == "")
         {
            return;
         }
         if(logMsg)
         {
            displayMessage("Parts: " + this.topLevel.PartInfos.length,2);
         }
         var parts:Array = [];
         for(part in this.topLevel.PartInfos)
         {
            parts.push(this.topLevel.PartInfos[part].NameTextField.text.toUpperCase());
            if(logMsg)
            {
               displayMessage(parts[part] + " [" + int(this.topLevel.PartInfos[part].HealthBarIndicator.scaleX * 100) + "] " + this.topLevel.PartInfos[part].ChanceToHit.text + (this.topLevel.SelectedPart == part ? " [S]" : ""),2);
            }
         }
         var foundTarget:Boolean = false;
         var foundPart:Boolean = false;
         for(prioTarget in config.priorities)
         {
            if(config.priorities[prioTarget] != null)
            {
               prioLookup = prioTarget.toUpperCase();
               if(!config.useTargetNames || this.targetName.indexOf(prioLookup) != -1)
               {
                  if(config.useTargetNames)
                  {
                     foundTarget = true;
                     if(logMsg)
                     {
                        displayMessage("Found target: " + prioLookup);
                     }
                  }
                  for each(altPriority in config.priorities[prioTarget])
                  {
                     for(part in parts)
                     {
                        if(parts[part].indexOf(altPriority.partName) != -1)
                        {
                           if(!foundTarget && !config.useTargetNames && altPriority == config.priorities[prioTarget][0])
                           {
                              foundTarget = true;
                              if(logMsg)
                              {
                                 displayMessage("Found target: " + prioLookup,1);
                              }
                           }
                           if(isValidAlternative(part,altPriority))
                           {
                              if(logMsg)
                              {
                                 displayMessage("Found part " + parts[part] + ", id: " + part,1);
                              }
                              this.topLevel.BGSCodeObj.SelectPart(part);
                              foundPart = true;
                              break;
                           }
                        }
                     }
                     if(foundPart)
                     {
                        break;
                     }
                  }
                  if(foundTarget)
                  {
                     break;
                  }
               }
            }
         }
         if(!foundPart)
         {
            for(part in parts)
            {
               if(parts[part].indexOf(config.defaultPriority) != -1)
               {
                  if(logMsg)
                  {
                     displayMessage("Default priority, selecting part " + part + ": " + parts[part],1);
                  }
                  this.topLevel.BGSCodeObj.SelectPart(part);
                  break;
               }
            }
         }
      }
      
      private function isValidAlternative(partId:uint, altConf:Object) : Boolean
      {
         var part:* = this.topLevel.PartInfos[partId];
         if(part != null)
         {
            if(altConf.notCrippled && part.HealthBarIndicator.scaleX == 0)
            {
               return false;
            }
            if(Number(part.ChanceToHit.text.replace("%","")) < altConf.minHitChance)
            {
               return false;
            }
            return true;
         }
         return false;
      }
      
      private function isTargetLocked() : Boolean
      {
         if(!config || !this.targetName)
         {
            return false;
         }
         if(config.lockPriorityTarget)
         {
            return indexOfCaseInsensitiveString(config.lockPriorityTargetExcluded,this.targetName) == -1;
         }
         return indexOfCaseInsensitiveString(config.lockPriorityTargetExcluded,this.targetName) != -1;
      }
      
      public function showHUDChildren() : void
      {
         if(!this.topLevel)
         {
            return;
         }
         var i:int = 0;
         while(i < this.topLevel.numChildren)
         {
            if(this.topLevel.getChildAt(i) is Loader)
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i).content));
            }
            else
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i)));
            }
            i++;
         }
      }
   }
}
