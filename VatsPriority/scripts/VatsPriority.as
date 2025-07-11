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
       
      
      private var topLevel:*;
      
      private var debug_tf:TextField;
      
      private var lastConfig:String;
      
      private var config:Object;
      
      private var isHUDMenu:Boolean = false;
      
      private var hudTools:SharedHUDTools;
      
      private var targetName:String = "";
      
      private var targetTimer:Timer;
      
      public function VatsPriority()
      {
         super();
         this.createDebugTf();
         this.loadConfig();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
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
         this.debug_tf.text = this.debug_tf.text + "\n" + str;
         this.debug_tf.visible = true;
         this.debug_tf.scrollV = this.debug_tf.maxScrollV;
      }
      
      private function loadConfig() : void
      {
         var loaderComplete:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            loaderComplete = function(param1:Event):void
            {
               try
               {
                  config = new JSONDecoder(loader.data,true).getValue();
                  DEBUG = isHUDMenu ? -1 : config.debug;
                  config.defaultPriority = config.defaultPriority != null ? config.defaultPriority.toUpperCase() : "HEAD";
                  config.lockPriorityTarget = Boolean(config.lockPriorityTarget);
                  if(config.priorities == null)
                  {
                     config.priorities = {};
                  }
                  for(prio in config.priorities)
                  {
                     if(config.priorities[prio] != null && config.priorities[prio] is String)
                     {
                        config.priorities[prio] = config.priorities[prio].toUpperCase();
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
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         }
         catch(e:Error)
         {
            displayMessage(FULL_MOD_NAME + " | Error loading config: " + e,0);
         }
      }
      
      private function ioErrorHandler(event:IOErrorEvent) : void
      {
         displayMessage(FULL_MOD_NAME + " | Error loading config :: " + event.text,0);
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == "HUDMenu")
            {
               DEBUG = -1;
               this.isHUDMenu = true;
               this.hudTools = new SharedHUDTools(HUD_TOOLS_SENDER_NAME);
               this.initTargetTimer();
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
                  stage.addEventListener(EVENT_VATS_PRIORITY_REFRESH,this.onRefreshActionDisplay);
                  stage.addEventListener(EVENT_VATS_PRIORITY_UPDATE_TARGET,this.onTargetChanged);
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
      
      private function initTargetTimer() : void
      {
         this.targetTimer = new Timer(50);
         this.targetTimer.addEventListener(TimerEvent.TIMER,this.updateTargetName);
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
               setTimeout(this.hudTools.SendMessage,50,MOD_NAME,this.targetName);
            }
         }
         catch(e:*)
         {
            displayMessage("Error updating TargetName: " + e,0);
         }
      }
      
      private function onHUDModeUpdate(event:*) : void
      {
         if(event == null || event.data == null)
         {
            return;
         }
         if(this.isHUDMenu)
         {
            if(event.data.hudMode == HUDModes.VATS_MODE)
            {
               this.targetTimer.start();
            }
            else
            {
               this.targetTimer.reset();
               this.targetName = "";
            }
         }
      }
      
      public function onReceiveMessage(sender:String, msg:String) : void
      {
         displayMessage("Received message from " + sender + ": " + msg,0);
         if(sender == HUD_TOOLS_SENDER_NAME)
         {
            this.targetName = msg.toUpperCase();
            displayMessage("Target name set to: \"" + this.targetName + "\"",0);
            this.setPriority();
         }
      }
      
      public function onRefreshActionDisplay(event:Event) : void
      {
         if(!config || !config.lockPriorityTarget)
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
         if(!this.topLevel || !this.topLevel.PartInfos || this.topLevel.PartInfos.length == 0)
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
               displayMessage(parts[part] + (this.topLevel.SelectedPart == part ? " [S]" : ""),2);
            }
         }
         var foundTarget:Boolean = false;
         for(prio in config.priorities)
         {
            if(config.priorities[prio] != null)
            {
               prioLookup = prio.toUpperCase();
               if(this.targetName == "" || this.targetName.indexOf(prioLookup) != -1)
               {
                  for(part in parts)
                  {
                     if(parts[part].indexOf(config.priorities[prio]) != -1)
                     {
                        if(logMsg)
                        {
                           displayMessage("Found target " + prioLookup + ", selecting part " + part + ": " + parts[part],1);
                        }
                        this.topLevel.BGSCodeObj.SelectPart(part);
                        foundTarget = true;
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
         if(!foundTarget)
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
