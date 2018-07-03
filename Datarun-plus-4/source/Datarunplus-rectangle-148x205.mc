class Datarunplus4App extends Toybox.Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new DatarunView() ];
    }
}


class DatarunView extends Toybox.WatchUi.DataField {
	//!Get battery-status
	using Toybox.System as Sys;
	using Toybox.Lang;
	using Toybox.WatchUi as Ui;
	var stats = Sys.getSystemStats();
	var pwr = stats.battery;
	var batStr = Lang.format( "$1$%", [ pwr.format( "%2d" ) ] );

	//!Get device info
	var mySettings = System.getDeviceSettings();
	var screenWidth = mySettings.screenWidth;
	var screenShape = mySettings.screenShape;
	var screenHeight = mySettings.screenHeight;
	var distanceUnits = mySettings.distanceUnits;
	var watchType = mySettings.partNumber;
	var is24Hour = mySettings.is24Hour;   //!boolean
	var isTouchScreen = mySettings.isTouchScreen;  //!boolean
	var numberis24Hour = 0;
	var numberisTouchScreen = 0;

	
    hidden var uHrZones                     = [ 93, 111, 130, 148, 167, 185 ];
    hidden var unitP                        = 1000.0;
    hidden var unitD                        = 1000.0;
    var Pace1 								= 0;
    var Pace2 								= 0;
    var Pace3 								= 0;
	var Pace4 								= 0;
    var Pace5 								= 0;
    var mETA								= 0;
        var aaltitude = 0;
        var mlastaltitude = 0;
		var mElevationGain = 0;
        var mElevationLoss = 0;
        var mElevationDiff = 0;
        var mrealElevationGain = 0;
        var mrealElevationLoss = 0;
        var mrealElevationDiff = 0;

    hidden var uTimerDisplay                = 0;
    //! 0 => Timer
    //! 1 => Lap time
    //! 2 => Last lap time
    //! 3 => Average lap time

    hidden var uDistDisplay                 = 0;
    //! 0 => Total distance
    //! 1 => Lap distance
    //! 2 => Last lap distance

    hidden var uHeartratefield                 = 0;
    //! 0 => Heartrate
    //! 1 => Heartrate zone
    //! 2 => No heartrate, larger pace field

    hidden var uPacefield                 = 0;
    //! 0 => Pace in minutes per km/mile
    //! 1 => Pace in seconds per 100 meter
    //! 2 => Speed in km/mile per hour
        
    hidden var uRoundedPace                 = true;
    //! true     => Show current pace as Rounded Pace (i.e. rounded to 5 second intervals)
    //! false    => Show current pace without rounding (i.e. 1-second resolution)

	hidden var uMaxColoringPace             = true;
    //! true     => Show 5 colors in pacefield in middle row (-10%<, -5%<, -5% - 5%, >5%, >10%)
    //! false    => Show 3 colors in pacefield in middle row (-5%<, -5% - 5%, >5%)

	hidden var uColoringPaceFromAver        = true;
    //! true     => Use average pace for colors in pacefield in middle row
    //! false    => Use pace based on desired finish time for colors  	

	hidden var uAveragedPace                = true;
    //! true     => Show current pace as Averaged Pace (i.e. average of the last 5 seconds)
    //! false    => Show current pace without averaging (i.e. pace at this second\)

	hidden var uBlackBackground             = true;
    //! true     => Use black background
    //! false    => Use white background

    hidden var uBacklight                   = false;
    //! true     => Force the backlight to stay on permanently
    //! false    => Use the defined backlight timeout as normal

    hidden var uShowlaps                   = false;
    //! true     => Show number of laps
    //! false    => Show current time

	hidden var uMiddlerightMetric           = 13;    //! Data to show in middle right field
    hidden var uBottomLeftMetric            = 0;    //! Data to show in bottom left field
    hidden var uBottomRightMetric           = 1;    //! Data to show in bottom right field
    //! Lower fields enum:
    //! 0 => (overall) average pace
    //! 1 => Lap pace
    //! 2 => Last lap pace
    //! 3 => Altitude
    //! 4 => Elevation gain
    //! 5 => Elevation loss
    //! 6 => ETA (finish time)
    //! 7 => Deviation from finish time
    //! 8 => Required pace for finish time
    //! 9 => Heartrate
    //! 10 => Heartrate zone
    //! 11 => Stryd footpod power
    //! 13 => Cadence (only for middle right field)
        
    //! Race distance
    hidden var uRacedistance                    = 42195;

    //! Race distance
    hidden var uRacetime							= "04:00:00";

    //! Which average pace metric should be used as the reference for deviation of the current pace? (see above)
    hidden var uTargetPaceMetric            = 0;

    //! License serial
    hidden var umyNumber                    = 0;
    
    //! Show demoscreen
    hidden var uShowDemo					= false;
    
    //! Use timer of last lap to calculate ETA
    hidden var uETAfromLap = true;
    
    hidden var mStartStopPushed             = 0;    //! Timer value when the start/stop button was last pushed

    hidden var mStoppedTime                 = 0;
    hidden var mStoppedDistance             = 0;
    hidden var mPrevElapsedDistance         = 0;

    hidden var mLaps                        = 1;
    hidden var mLastLapDistMarker           = 0;
    hidden var mLastLapTimeMarker           = 0;
    hidden var mLastLapStoppedTimeMarker    = 0;
    hidden var mLastLapStoppedDistMarker    = 0;

    hidden var mLastLapTimerTime            = 0;
    hidden var mLastLapElapsedDistance      = 0;
    hidden var mLastLapMovingSpeed          = 0;
    
    hidden var secsWithAltitude = 0;

    function initialize() {
        DataField.initialize();

        uHrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());


         var mApp = Application.getApp();
         uTimerDisplay       = mApp.getProperty("pTimerDisplay");
         uDistDisplay        = mApp.getProperty("pDistDisplay");
         uBottomLeftMetric   = mApp.getProperty("pBottomLeftMetric");
         uBottomRightMetric  = mApp.getProperty("pBottomRightMetric");
         uMiddlerightMetric   = mApp.getProperty("pMiddlerightMetric");         
         uRoundedPace        = mApp.getProperty("pRoundedPace");
         uMaxColoringPace    = mApp.getProperty("pMaxColoringPace");
         uColoringPaceFromAver= mApp.getProperty("pColoringPaceFromAver");
         uAveragedPace       = mApp.getProperty("pAveragedPace");
         uBlackBackground    = mApp.getProperty("pBlackBackground");
         uBacklight          = mApp.getProperty("pBacklight");
         umyNumber			 = mApp.getProperty("myNumber");
         uShowDemo			 = mApp.getProperty("pShowDemo");
         uShowlaps			 = mApp.getProperty("pShowlaps");
         uHeartratefield	 = mApp.getProperty("pHeartratefield");
         uRacedistance		 = mApp.getProperty("pRacedistance");
         uRacetime			 = mApp.getProperty("pRacetime");
         uETAfromLap		 = mApp.getProperty("pETAfromLap");
         uPacefield		 	= mApp.getProperty("pPacefield");
         
        if (uRacedistance < 1) { 
			uRacedistance 		= 42195;
		}


        if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
            unitP = 1609.344;
        }

        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
            unitD = 1609.344;
        }
		uRacedistance = (unitD/1000)*uRacedistance;
    }


    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        //! If enabled, switch the backlight on in order to make it stay on
        if (uBacklight) {
             Attention.backlight(true);
        }
        //! Calculate elevation differences and rounding altitude
        aaltitude = 0;
        if (info.altitude != null) {        
          aaltitude = Math.round(info.altitude).toNumber();
          secsWithAltitude = secsWithAltitude + 1;
          if (info.timerTime != null and info.timerTime > 1000) {
          	secsWithAltitude = secsWithAltitude + 1;
          	if (secsWithAltitude == 0 or secsWithAltitude == 1 ) {
          		mlastaltitude = aaltitude;
          	} else { 
          		mrealElevationDiff = aaltitude - mlastaltitude;
          	}
          } else { 
          	mrealElevationDiff = 0;       	
          }
          if (mrealElevationDiff > 0 ) {
          	mrealElevationGain = mrealElevationDiff + mrealElevationGain;
          } else {
          	mrealElevationLoss =  mrealElevationLoss - mrealElevationDiff;
          }  
          mlastaltitude = aaltitude;
          mElevationLoss = Math.round(mrealElevationLoss).toNumber();
          mElevationGain = Math.round(mrealElevationGain).toNumber();
        }
    }

    //! Store last lap quantities and set lap markers
    function onTimerLap() {
        var info = Activity.getActivityInfo();

        mLastLapTimerTime        = (info.timerTime - mLastLapTimeMarker) / 1000;
        mLastLapElapsedDistance  = (info.elapsedDistance != null) ? info.elapsedDistance - mLastLapDistMarker : 0;


        mLaps++;
        mLastLapDistMarker           = info.elapsedDistance;
        mLastLapTimeMarker           = info.timerTime;
        mLastLapStoppedTimeMarker    = mStoppedTime;
        mLastLapStoppedDistMarker    = mStoppedDistance;

    }



    //! Current activity is ended
    function onTimerReset() {
        mPrevElapsedDistance        = 0;

        mLaps                       = 1;
        mLastLapDistMarker          = 0;
        mLastLapTimeMarker          = 0;

        mLastLapTimerTime           = 0;
        mLastLapElapsedDistance     = 0;

        mStartStopPushed            = 0;
    }


    //! Do necessary calculations and draw fields.
    //! This will be called once a second when the data field is visible.
    function onUpdate(dc) {
        var info = Activity.getActivityInfo();
    	
    	//! Setup back- and foregroundcolours
        var mColour;
        var mColourFont;
		var mColourFont1;
        var mColourLine;
        var mColourBackGround;

		if (uBlackBackground == true ){
			mColourFont = Graphics.COLOR_WHITE;
			mColourFont1 = Graphics.COLOR_WHITE;
			mColourLine = Graphics.COLOR_YELLOW;
			mColourBackGround = Graphics.COLOR_BLACK;
		} else {
			mColourFont = Graphics.COLOR_BLACK;
			mColourFont1 = Graphics.COLOR_BLACK;
			mColourLine = Graphics.COLOR_RED;
			mColourBackGround = Graphics.COLOR_WHITE;
		}
		
		//! Set background color
        dc.setColor(mColourBackGround, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, 240, 240);
        	
    	//! Check license
		if (is24Hour == false) {
        	numberis24Hour = 51;
    	} else {
    		numberis24Hour = 23;
    	}
    	if (isTouchScreen == false) {
        	numberisTouchScreen = 87;
    	} else {
    		numberisTouchScreen = 5;
    	}
		var deviceID1 = (screenWidth-screenShape)*(screenHeight+distanceUnits)+numberis24Hour+numberisTouchScreen;
		var deviceID2 = numberis24Hour+numberisTouchScreen;
		var mtest = (numberisTouchScreen+distanceUnits)*screenWidth+(screenHeight-numberis24Hour)*screenShape;
		
        //! Calculate lap distance
        var mLapElapsedDistance = 0.0;
        if (info.elapsedDistance != null) {
            mLapElapsedDistance = info.elapsedDistance - mLastLapDistMarker;
        }

        //! Calculate lap time and convert timers from milliseconds to seconds
        var mTimerTime      = 0;
        var mLapTimerTime   = 0;

        if (info.timerTime != null) {
            mTimerTime = info.timerTime / 1000;
            mLapTimerTime = (info.timerTime - mLastLapTimeMarker) / 1000;
        }

        //! Calculate lap speeds
        var mLapSpeed = 0.0;
        var mLastLapSpeed = 0.0;
        if (mLapTimerTime > 0 && mLapElapsedDistance > 0) {
            mLapSpeed = mLapElapsedDistance / mLapTimerTime;
        }
        if (mLastLapTimerTime > 0 && mLastLapElapsedDistance > 0) {
            mLastLapSpeed = mLastLapElapsedDistance / mLastLapTimerTime;
        }


        //! Calculate ETA
        if (info.elapsedDistance != null && info.timerTime != null) {
            if (uETAfromLap == true ) {
            	if (mLastLapTimerTime > 0 && mLastLapElapsedDistance > 0 && mLaps > 1) {
            		if (uRacedistance > info.elapsedDistance) {
            			mETA = info.timerTime/1000 + (uRacedistance - info.elapsedDistance)/ mLastLapSpeed;
            		} else {
            			mETA = 0;
            		}
            	}
            } else {
            	if (info.elapsedDistance > 5) {
            		mETA = uRacedistance / (1000*info.elapsedDistance/info.timerTime);
            	}
            }
        }


		//! Determine required finish time and calculate required pace 	
        var mRacehour = uRacetime.substring(0, 2);
        var mRacemin = uRacetime.substring(3, 5);
        var mRacesec = uRacetime.substring(6, 8);
        mRacehour = mRacehour.toNumber();
        mRacemin = mRacemin.toNumber();
        mRacesec = mRacesec.toNumber();
        var mRacetime = mRacehour*3600 + mRacemin*60 + mRacesec;

        
        if (uShowDemo == false) {
        	if (umyNumber != mtest && mTimerTime > 900)  {
        		uShowDemo = true;        		
        	}
        }
        
       
        

     if (uShowDemo == false ) {
        //!
        //! Draw colour indicators
        //!
		
        //! HR zone
        mColour = Graphics.COLOR_LT_GRAY; //! No zone default light grey
        var mCurrentHeartRate = 0;
        var  mCurrentHeartZone = 1;
        if (info.currentHeartRate != null) {
            mCurrentHeartRate = info.currentHeartRate;
            if (uHrZones != null) {
                if (mCurrentHeartRate >= uHrZones[4]) {
                    mColour = Graphics.COLOR_RED;        //! Maximum (Z5)
                    mCurrentHeartZone = 5;
                } else if (mCurrentHeartRate >= uHrZones[3]) {
                    mColour = Graphics.COLOR_ORANGE;    //! Threshold (Z4)
                    mCurrentHeartZone = 4;
                } else if (mCurrentHeartRate >= uHrZones[2]) {
                    mColour = Graphics.COLOR_GREEN;        //! Aerobic (Z3)
                    mCurrentHeartZone = 3;
                } else if (mCurrentHeartRate >= uHrZones[1]) {
                    mColour = Graphics.COLOR_BLUE;        //! Easy (Z2)
                    mCurrentHeartZone = 2;
                } //! Else Warm-up (Z1) and no zone both inherit default light grey here
            }
        }

       	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
       	dc.fillRectangle(0, 104, 74, 15);


        var mColourCadence = Graphics.COLOR_LT_GRAY;
        if (info.currentCadence != null) {
            if (info.currentCadence > 183) {
                mColourCadence = Graphics.COLOR_PURPLE;
            } else if (info.currentCadence >= 174) {
                mColourCadence = Graphics.COLOR_BLUE;
            } else if (info.currentCadence >= 164) {
                mColourCadence = Graphics.COLOR_GREEN;
            } else if (info.currentCadence >= 153) {
                mColourCadence = Graphics.COLOR_ORANGE;
            } else if (info.currentCadence >= 120) {
                mColourCadence = Graphics.COLOR_RED;
            } //! Else no cadence or walking/stopped inherits default light grey here
        }
        if (uMiddlerightMetric == 13) {
        	dc.setColor(mColourCadence, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(75, 104, 74, 15);
		}

		//! Draw separator lines
        dc.setColor(mColourLine, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        //! Horizontal dividers
        dc.drawLine(0, 50,  205, 50);
		dc.drawLine(0, 103, 205, 103);
		dc.drawLine(0, 157, 205, 157);

        //! Top vertical divider
        dc.drawLine(74, 0,  74, 50);

        //! Bottom vertical divider
        dc.drawLine(74, 103, 74, 205);

        //! Vertical mini-field separator
        dc.drawLine(113, 50, 113, 103);

		//! Side battery indicator
        mColour = Graphics.COLOR_BLACK;
		dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(124, 73, 14, 28);
		dc.fillRectangle(128, 70, 6, 3);
		
		mColour = Graphics.COLOR_BLACK;
		dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(126, 75, 10, 24);
		
		mColour = Graphics.COLOR_WHITE;
		dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(128, 79, 6, 1);
		dc.fillRectangle(128, 83, 6, 1);
		dc.fillRectangle(127, 87, 8, 1);
		dc.fillRectangle(128, 91, 6, 1);
		dc.fillRectangle(128, 95, 6, 1);
		
		

		var Endstatuspwrbr = 0.24*(100-pwr)  ;
		var Startstatuspwrbr = 75  ;
		dc.fillRectangle(126, Startstatuspwrbr, 10, Endstatuspwrbr);


        //!
        //! Draw field values
        //! =================
        //!



		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);
		
		//! Show number of laps or clock with current time in top
		if (uShowlaps == true) {
			 dc.drawText(127, 51, Graphics.FONT_XTINY, mLaps, Graphics.TEXT_JUSTIFY_CENTER);
			 dc.drawText(133, 51, Graphics.FONT_XTINY, "lap", Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			var myTime = Toybox.System.getClockTime(); 
	    	var strTime = myTime.hour.format("%02d") + ":" + myTime.min.format("%02d");
			dc.drawText(131, 51, Graphics.FONT_XTINY, strTime, Graphics.TEXT_JUSTIFY_CENTER);
		}
		
        //! Top row left: time
        var mTime = mTimerTime;
        var lTime = "Timer";
        if (uTimerDisplay == 1) {
            mTime = mLapTimerTime;
            lTime = "LapTime";
        } else if (uTimerDisplay == 2) {
            mTime = mLastLapTimerTime;
            lTime = "Last Lap";
        } else if (uTimerDisplay == 3) {
            mTime = mTimerTime / mLaps;
            lTime = "Avg LapT";
        }

        var fTimerSecs = (mTime % 60).format("%02d");
        var fTimer = (mTime / 60).format("%d") + ":" + fTimerSecs;  //! Format time as m:ss
        var x = 37;
        if (mTime > 3599) {
            //! (Re-)format time as h:mm(ss) if more than an hour
            fTimer = (mTime / 3600).format("%d") + ":" + (mTime / 60 % 60).format("%02d");
            x = 26;
            dc.drawText(55, 22, Graphics.FONT_NUMBER_MILD, fTimerSecs, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.drawText(x, 29, Graphics.FONT_NUMBER_MEDIUM, fTimer, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(37, 5, Graphics.FONT_XTINY,  lTime, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Top row right: distance
        var mDistance = (info.elapsedDistance != null) ? info.elapsedDistance / unitD : 0;
        var lDistance = "Distance";
        if (uDistDisplay == 1) {
            mDistance = mLapElapsedDistance / unitD;
            lDistance = "Lap Dist.";
        } else if (uDistDisplay == 2) {
            mDistance = mLastLapElapsedDistance / unitD;
            lDistance = "L-1 Dist.";
        }

        var fString = "%.2f";
         if (mDistance > 100) {
             fString = "%.1f";
         }
         
         
        dc.drawText(111, 29, Graphics.FONT_NUMBER_MEDIUM, mDistance.format(fString), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(111, 5, Graphics.FONT_XTINY,  lDistance, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Centre middle: current pace
        var Averagespeedinmpersec 			= 0;
        var fCurrentPace 					= 0;
        var currentSpeedtest				= 0;
        if (info.currentSpeed != null) {
        	currentSpeedtest = info.currentSpeed; 
        }
        if (currentSpeedtest > 0) {
            if (uAveragedPace == true) {
            	//! Calculate average pace
				if (info.currentSpeed != null) {
        		Pace5 								= Pace4;
        		Pace4 								= Pace3;
        		Pace3 								= Pace2;
        		Pace2 								= Pace1;
        		Pace1								= info.currentSpeed; 
        		} else {
					Pace5 								= Pace4;
    	    		Pace4 								= Pace3;
        			Pace3 								= Pace2;
        			Pace2 								= Pace1;
        			Pace1								= 0;
				}
				Averagespeedinmpersec= (Pace1+Pace2+Pace3+Pace4+Pace5)/5;
				if (uRoundedPace) {
                	fCurrentPace 					= unitP/(Math.round( (unitP/Averagespeedinmpersec) / 5 ) * 5);
                } else {
                	fCurrentPace 					= Averagespeedinmpersec;
                }
			} else {
				if (uRoundedPace) {
                	fCurrentPace = unitP/(Math.round( (unitP/info.currentSpeed) / 5 ) * 5);
                } else {
                	fCurrentPace = info.currentSpeed;
                }
            }
         	
			if ( uPacefield == 0 ) {
            	dc.drawText(65, 74, Graphics.FONT_NUMBER_THAI_HOT, fmtPace(fCurrentPace), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            } else if (uPacefield == 1) {
            	var fCurrentPace = 100/info.currentSpeed;
            	fString = "%.1f";
            	dc.drawText(65, 74, Graphics.FONT_NUMBER_THAI_HOT, fCurrentPace.format(fString), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
            	var fCurrentPace = 3.6*info.currentSpeed*1000/unitP;
            	fString = "%.1f";
            	dc.drawText(65, 74, Graphics.FONT_NUMBER_THAI_HOT, fCurrentPace.format(fString), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
        
        if ( uColoringPaceFromAver == true ) {
        	if (info.averageSpeed != null and info.averageSpeed > 0.1) {
        		uTargetPaceMetric = unitD/info.averageSpeed;
        	}
        } else {
        		uTargetPaceMetric = unitD*mRacetime/uRacedistance;
        }

        //! Current pace vs target pace colour indicator
        if ( uTargetPaceMetric > 2 ) {
        	mColour = Graphics.COLOR_LT_GRAY;
        	if (info.currentSpeed != null) { 
       	     var uTargetSpeed = unitP/uTargetPaceMetric;
        	    if (uTargetSpeed > 0) {
            	    var paceDeviation = (fCurrentPace / uTargetSpeed);
            	    if (uMaxColoringPace == true ) {
                		if (paceDeviation < 0.95) {    //! More than 5% slower
                			if (paceDeviation < 0.90) {    //! More than 10% slower
                				mColour = Graphics.COLOR_RED;
       		         		} else {
            	        		mColour = Graphics.COLOR_ORANGE;
                	    	}
              	  		} else if (paceDeviation <= 1.05) {    //! Within +/-5% of target pace
                	    	mColour = Graphics.COLOR_GREEN;
              	  		} else {  
                			if (paceDeviation > 1.10) {   //! More than 10% faster
                				mColour = Graphics.COLOR_PURPLE;
            	    		} else {
                	    		mColour = Graphics.COLOR_BLUE;
                	    	}
            	    	}
            	    } else {
            	    	if (paceDeviation < 0.95) {    //! More than 5% slower
            	    		mColour = Graphics.COLOR_RED;
            	    	} else if (paceDeviation > 1.05) {
            	    		mColour = Graphics.COLOR_PURPLE;
            	    	} else { 
            	    		mColour = Graphics.COLOR_GREEN;
            	    	}
            	    }
          	  }
        	}    
        } else {
        mColour = mColourFont;
        }
        
        dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
       	dc.fillRectangle(0, 51, 12, 52);
		
       	if ( uTargetPaceMetric > 2 ) {
           	mColour = mColourFont;
       	} else {
       		mColour = mColourBackGround;
       	}
       	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
       	if ( uPacefield == 2 ) {
			dc.drawText(2, 56, Graphics.FONT_XTINY,  "S", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 66, Graphics.FONT_XTINY,  "p", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 76, Graphics.FONT_XTINY,  "e", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 86, Graphics.FONT_XTINY,  "e", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 96, Graphics.FONT_XTINY,  "d", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
       	} else {	
			dc.drawText(2, 61, Graphics.FONT_XTINY,  "P", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 71, Graphics.FONT_XTINY,  "a", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 81, Graphics.FONT_XTINY,  "c", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(2, 91, Graphics.FONT_XTINY,  "e", Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
       	}

		
		mColour = mColourFont;
		dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        //! Centre left: heart rate 

       	if (uHeartratefield == 0) {
           	dc.drawText(37, 136, Graphics.FONT_NUMBER_MEDIUM, mCurrentHeartRate, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       		dc.drawText(36, 110, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
           	dc.drawText(37, 136, Graphics.FONT_NUMBER_MEDIUM, mCurrentHeartZone, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       		dc.drawText(36, 110, Graphics.FONT_XTINY, "HR zone", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
            		

		
        //! Centre right: cadence
        //! Centre right: cadence
        var fieldValue     = 0.0;
        var fieldLabel     = "A Pace";
        var isPace         = true;
        if (uMiddlerightMetric == 0 && info.averageSpeed != null) {
            fieldValue = info.averageSpeed;
            //fieldLabel = "A Pace";
        } else if (uMiddlerightMetric == 1) {
            fieldValue = mLapSpeed;
            fieldLabel = "L Pace";
        } else if (uMiddlerightMetric == 2) {
            fieldValue = mLastLapSpeed;
            fieldLabel = "L-1Pace";
        }  else if (uMiddlerightMetric == 3) {
           	fieldValue = aaltitude;
            fieldLabel = "Altitude";
        }  else if (uMiddlerightMetric == 4) {
           	fieldValue = mElevationGain;
            fieldLabel = "EL gain";
        }  else if (uMiddlerightMetric == 5) {
           	fieldValue = mElevationLoss;
            fieldLabel = "EL loss";
        } else if (uMiddlerightMetric == 6) {
           	fieldValue = 0;
            fieldLabel = "Error";
        } else if (uMiddlerightMetric == 8) {
        	fieldLabel = "Rq pace ";
        	if (info.elapsedDistance != null and info.timerTime != null and mRacetime != info.timerTime/1000 and mRacetime > info.timerTime/1000) {
        			fieldValue = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000); 
        	}
        }  else if (uMiddlerightMetric == 9) {
           	fieldValue = mCurrentHeartRate;
            fieldLabel = "HR rate";
        }  else if (uMiddlerightMetric == 10) {
           	fieldValue = mCurrentHeartZone;
            fieldLabel = "HR zone";
        }  else if (uMiddlerightMetric == 11) {
           	fieldValue = 999;
            fieldLabel = "Power";
        }  else if (uMiddlerightMetric == 12) {
           	fieldValue = 9.99;
            fieldLabel = "T effect";
        }  else if (uMiddlerightMetric == 13) {
           	fieldValue = (info.currentCadence != null) ? info.currentCadence : 0;
            fieldLabel = "Cadence";
        }
             
        if (uMiddlerightMetric == 6 or uMiddlerightMetric == 7 or uMiddlerightMetric == 8) {
          	if (mETA < mRacetime) {
        		mColour = Graphics.COLOR_GREEN;
        	} else {
        		mColour = Graphics.COLOR_RED;
        	}
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(75, 104, 74, 15);
        	mColour = mColourFont1;	
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        }	
        	
        if ( uMiddlerightMetric == 7 ) {
        	dc.drawText(111, 136, Graphics.FONT_NUMBER_MEDIUM, EstimatedTimeSmall(fieldValue) , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       	} else if (uMiddlerightMetric == 6) {    
        	dc.drawText(111, 136, Graphics.FONT_NUMBER_MEDIUM , fieldValue , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        } else if (uMiddlerightMetric == 0 or uMiddlerightMetric == 1 or uMiddlerightMetric == 2 or uMiddlerightMetric == 8 ) {
        	if (fieldValue > 0) {
            	dc.drawText(111, 136, Graphics.FONT_NUMBER_MEDIUM, (isPace) ? fmtPace(fieldValue) : fieldValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else if ( uMiddlerightMetric == 3 or uMiddlerightMetric == 4 or uMiddlerightMetric == 5 or uMiddlerightMetric == 9 or uMiddlerightMetric == 10 or uMiddlerightMetric == 11 or uMiddlerightMetric == 13 ) {
        	dc.drawText(111, 136, Graphics.FONT_NUMBER_MEDIUM, (info.altitude != null) ? fieldValue : 0, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        } else if ( uMiddlerightMetric == 12 ) {
        	dc.drawText(111, 136, Graphics.FONT_NUMBER_MEDIUM, fieldValue.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }      
        dc.drawText(112, 110, Graphics.FONT_XTINY, fieldLabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
        //! Bottom left
        fieldValue     = 0.0;
        fieldLabel     = "A Pace";
        isPace         = true;
        if (uBottomLeftMetric == 0 && info.averageSpeed != null) {
            fieldValue = info.averageSpeed;
            //fieldLabel = "A Pace";
        } else if (uBottomLeftMetric == 1) {
            fieldValue = mLapSpeed;
            fieldLabel = "L Pace";
        } else if (uBottomLeftMetric == 2) {
            fieldValue = mLastLapSpeed;
            fieldLabel = "L-1Pace";
        }  else if (uBottomLeftMetric == 3) {
           	fieldValue = aaltitude;
            fieldLabel = "Altitude";
        }  else if (uBottomLeftMetric == 4) {
           	fieldValue = mElevationGain;
            fieldLabel = "EL gain";
        }  else if (uBottomLeftMetric == 5) {
           	fieldValue = mElevationLoss;
            fieldLabel = "EL loss";
        } else if (uBottomLeftMetric == 6) {
           	fieldValue = mETA*1000;
            fieldLabel = "ETA";
        } else if (uBottomLeftMetric == 7) {
        	fieldLabel = "Deviation ";
        	if ( mLaps == 1 ) {
        		fieldValue = 0;
        	} else {
        		fieldValue = 1000*Math.round(mRacetime - mETA).toNumber() ;
        	}
        	if (fieldValue < 0) {
        		fieldValue = - fieldValue;
        	}
        } else if (uBottomLeftMetric == 8) {
        	fieldLabel = "Req pace ";
        	if (info.elapsedDistance != null and info.timerTime != null and mRacetime != info.timerTime/1000 and mRacetime > info.timerTime/1000) {
        			fieldValue = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000); 
        	}
        }  else if (uBottomLeftMetric == 9) {
           	fieldValue = mCurrentHeartRate;
            fieldLabel = "HR rate";
        }  else if (uBottomLeftMetric == 10) {
           	fieldValue = mCurrentHeartZone;
            fieldLabel = "HR zone";
        }  else if (uBottomLeftMetric == 11) {
            fieldLabel = "Power";
        } else if (uBottomLeftMetric == 12) {
            fieldLabel = "T effect";
        }
        
        if (uBottomLeftMetric == 6 or uBottomLeftMetric == 7 or uBottomLeftMetric == 8) {
          	if (mETA < mRacetime) {
        		mColour = Graphics.COLOR_GREEN;
        	} else {
        		mColour = Graphics.COLOR_RED;
        	}
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(0, 158, 73, 13);
        	mColour = mColourFont1;	
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        }	
        	
        if ( uBottomLeftMetric == 7 ) {
        	dc.drawText(37, 186, Graphics.FONT_NUMBER_MEDIUM, EstimatedTimeSmall(fieldValue) , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       	} else if (uBottomLeftMetric == 6) {    
        				dc.drawText(37, 186, Graphics.FONT_NUMBER_MILD, EstimatedTime(fieldValue) , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        				
        } else if (uBottomLeftMetric == 0 or uBottomLeftMetric == 1 or uBottomLeftMetric == 2 or uBottomLeftMetric == 8 ) {
        	if (fieldValue > 0) {
            	dc.drawText(37, 186, Graphics.FONT_NUMBER_MEDIUM, (isPace) ? fmtPace(fieldValue) : fieldValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else if ( uBottomLeftMetric == 3 or uBottomLeftMetric == 4 or uBottomLeftMetric == 5 or uBottomLeftMetric == 9 or uBottomLeftMetric == 10 ) {
        	dc.drawText(37, 186, Graphics.FONT_NUMBER_MEDIUM, (info.altitude != null) ? fieldValue : 0, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.drawText(37, 163, Graphics.FONT_XTINY, fieldLabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Bottom right
        fieldValue     = 0.0;
        fieldLabel     = "A Pace";
        isPace         = true;
        if (uBottomRightMetric == 0 && info.averageSpeed != null) {
            fieldValue = info.averageSpeed;
            //fieldLabel = "A Pace";
        } else if (uBottomRightMetric == 1) {
            fieldValue = mLapSpeed;
            fieldLabel = "L Pace";
        } else if (uBottomRightMetric == 2) {
            fieldValue = mLastLapSpeed;
            fieldLabel = "L-1Pace";
        }  else if (uBottomRightMetric == 3) {
           	fieldValue = aaltitude;
            fieldLabel = "Altitude";
        }  else if (uBottomRightMetric == 4) {
           	fieldValue = mElevationGain;
            fieldLabel = "EL gain";
        }  else if (uBottomRightMetric == 5) {
           	fieldValue = mElevationLoss;
            fieldLabel = "EL loss";
        } else if (uBottomRightMetric == 6) {
           	fieldValue = mETA*1000;
            fieldLabel = "ETA";
        } else if (uBottomRightMetric == 7) {
         	fieldLabel = "  Deviation ";
        	if ( mLaps == 1 ) {
        		fieldValue = 0;
        	} else {
        		fieldValue = 1000*Math.round(mRacetime - mETA).toNumber() ;
        	}
        	if (fieldValue < 0) {
        		fieldValue = - fieldValue;
        	}
        } else if (uBottomRightMetric == 8) {
        	fieldLabel = "  Req pace";
        	if (info.elapsedDistance != null and info.timerTime != null and mRacetime != info.timerTime/1000 and mRacetime > info.timerTime/1000) {
        			fieldValue = (uRacedistance - info.elapsedDistance) / (mRacetime - info.timerTime/1000); 
        	}
        }  else if (uBottomRightMetric == 9) {
           	fieldValue = mCurrentHeartRate;
            fieldLabel = "HR rate";
        }  else if (uBottomRightMetric == 10) {
           	fieldValue = mCurrentHeartZone;
            fieldLabel = "HR zone";
        }  else if (uBottomRightMetric == 11) {
            fieldLabel = "Power";
        } else if (uBottomRightMetric == 12) {
            fieldLabel = "T effect";
        }
        if (uBottomRightMetric == 6 or uBottomRightMetric == 7 or uBottomRightMetric == 8) {
          	if (mETA < mRacetime) {
        		mColour = Graphics.COLOR_GREEN;
        	} else {
        		mColour = Graphics.COLOR_RED;
        	}
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(75, 158, 73, 13);
        	mColour = mColourFont1;	
        	dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        }	
        	
        if ( uBottomRightMetric == 7 ) {
        	dc.drawText(111, 186, Graphics.FONT_NUMBER_MEDIUM, EstimatedTimeSmall(fieldValue) , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       	} else if (uBottomRightMetric == 6) {    
        		dc.drawText(111, 186, Graphics.FONT_NUMBER_MILD, EstimatedTime(fieldValue) , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        } else if (uBottomRightMetric == 0 or uBottomRightMetric == 1 or uBottomRightMetric == 2 or uBottomRightMetric == 8 ) {
        	if (fieldValue > 0) {
            	dc.drawText(111, 186, Graphics.FONT_NUMBER_MEDIUM, (isPace) ? fmtPace(fieldValue) : fieldValue, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        } else if ( uBottomRightMetric == 3 or uBottomRightMetric == 4 or uBottomRightMetric == 5 or uBottomRightMetric == 9 or uBottomRightMetric == 10) {
        	dc.drawText(111, 186, Graphics.FONT_NUMBER_MEDIUM, (info.altitude != null) ? fieldValue : 0, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.drawText(111, 163, Graphics.FONT_XTINY, fieldLabel, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
        	
        
      } else {
		dc.setColor(mColourFont, Graphics.COLOR_TRANSPARENT);

		if (umyNumber == mtest) {
			dc.drawText(74, 60, Graphics.FONT_XTINY, "Registered !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(74, 120, Graphics.FONT_XTINY, "License code:", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(74, 160, Graphics.FONT_NUMBER_MEDIUM, mtest, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		} else {
      		dc.drawText(74, 30, Graphics.FONT_XTINY, "License needed !!", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      		dc.drawText(74, 60, Graphics.FONT_XTINY, "Run is recorded though", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(25, 122, Graphics.FONT_MEDIUM, "ID 1: ", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(100, 115, Graphics.FONT_NUMBER_MEDIUM, deviceID1, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(25, 177, Graphics.FONT_MEDIUM, "ID 2: " , Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(100, 170, Graphics.FONT_NUMBER_MEDIUM, deviceID2, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      	}

      	
		
      }
    }

    function EstimatedTime(secs) {
        var s = (secs).toLong();
        return (s / 3600000).format("%0d") + ":" + (s /60000 % 60).format("%02d") + ":" + (s /1000 % 60).format("%02d");
    }

    function EstimatedTimeSmall(secs) {
        var s = (secs).toLong();
        return (s /60000 % 60).format("%02d") + ":" + (s /1000 % 60).format("%02d");
    }

    function fmtPace(secs) {
        var s = (unitP/secs).toLong();
        return (s / 60).format("%0d") + ":" + (s % 60).format("%02d");
    }


}
