# vim: tabstop=4 expandtab

var PFD = {
	new: func(canvas_group)
	{
		var m = { parents: [PFD] };
		m.data = {};
		m.pfd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
			elsif( family == "Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
			elsif( family == "BoeingCDULarge" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";

		}
		canvas.parsesvg(m.pfd, "Aircraft/Instruments-3d/Farmin/G1000/Pages/PFD/PFD.svg", {'font-mapper': font_mapper});
		var Speed = {};

        var svg_keys = ["Horizon", "bankPointer","bankPointerLineL",
            "bankPointerLineR","HSI", "SlipSkid","HDGVAL","VSI",
		    "VSIText","HorizonLine", "PitchScale"];
		#speed
		svg_keys ~= ["LindSpeed","SpeedtLint1","SpeedtLint10","SpeedtLint100"];
		#alt
		svg_keys ~= ["AltLint10","AltLint100","AltLint1000","AltLint10000"];
		svg_keys ~= ["AltBigU1","AltBigU2","AltBigU3","AltBigU4","AltBigU5","AltBigU6",];
		svg_keys ~= ["AltBigD1","AltBigD2","AltBigD3","AltBigD4","AltBigD5","AltBigD6",];
		svg_keys ~= ["AltSmallU1","AltSmallU2","AltSmallU3","AltSmallU4","AltSmallU5","AltSmallU6",];
		svg_keys ~= ["AltSmallD1","AltSmallD2","AltSmallD3","AltSmallD4","AltSmallD5","AltSmallD6",];
		svg_keys ~= ["AltBigC","AltSmallC","LintAlt"];
		svg_keys ~= ["Marker","MarkerBG","MarkerText"];
		svg_keys ~= ["MAPL","MAPR"];

		svg_keys = svg_keys ~[];

		foreach(var key; svg_keys) {
			m[key] = nil;
			m[key] = m.pfd.getElementById(key);
            if (m[key] == nil) {
                print(sprintf("Element %s not found.", key));
                continue
            }
			m[key].updateCenter();
			m[key].trans	= m[key].createTransform();
			m[key].rot		= m[key].createTransform();
		};

		#5,715272637
		svg_keys = ["Lind"];
		svg_keys ~= ["CompassRot", "HSB"];
		svg_keys ~= ["COMPASSNAV1", "NAV1CDI", "NAV1TO", "NAV1FROM"];
		svg_keys ~= ["COMPASSNAV2", "NAV2CDI", "NAV2TO", "NAV2FROM"];
		svg_keys ~= ["COMPASSGPS", "GPSCDI"];
		svg_keys ~= ["COMPASSADF"];
		svg_keys ~= ["CRS", "CRSVAL"];
		svg_keys ~= ["GS", "GSI"];
        svg_keys ~= ["HDGFAIL", "HDGVAL", "HDG"];
        svg_keys ~= ["HDGTGTVAL", "IASTGTVAL"];

		foreach(var key; svg_keys) {
			m[key] = nil;
			m[key] = m.pfd.getElementById(key);
            if (m[key] == nil) {
                print(sprintf("Element %s not found.", key));
                continue
            }
		};

		foreach(var key; ["rect6051"]) {
			m.pfd.getElementById(key).hide();
		};

		#clip
		#test = m.Horizon.set("clip", 'rect,(128,896,640,128)');
		m.bankPointerLineL.set("clip", "rect(0,1024,768,459.500)");
		m.bankPointerLineR.set("clip", "rect(0,459.500,768,0)");
		m.PitchScale.set("clip", "rect(134,590,394,330)");
		m.AltLint10.set("clip", "rect(251.5,1024,317.5,0)");
		m.AltLint100.set("clip", "rect(264.5,1024,304.5,0)");
		m.AltLint1000.set("clip", "rect(264.5,1024,304.5,0)");
		m.AltLint10000.set("clip", "rect(264.5,1024,304.5,0)");
		m.SpeedtLint1.set("clip", "rect(251.5,1024,317.5,0)");
		m.SpeedtLint10.set("clip", "rect(264.5,1024,304.5,0)");
		m.SpeedtLint100.set("clip", "rect(264.5,1024,304.5,0)");

		m.LintAlt.set("clip", "rect(114px, 1024px, 455px, 0px)");
		#note to my self clip for the Pitch Scale is: top = 134 right = 590 bottem = 394 left = 330

		#Enable map
		m.MAPd = m.pfd.createChild("map");
		m.MAPd.setController("Aircraft position");
		m.MAPd.setRange(25);
		m.MAPd.setTranslation(861,601);
		var r = func(name,vis=1,zindex=nil) return caller(0)[0];
		foreach(var type; [r('TFC'), r('APS')] )
			m.MAPd.addLayer(factory: canvas.SymbolLayer, type_arg: type.name, visible: type.vis, priority: type.zindex,);
		m.MAPd.set("clip", "rect(493, 1011, 709, 711).setRotation(45+D2R,[0,0])");
		m.MAPd.hide();

		foreach(key; ["ComparatorWindow", "Reversionary_Sensor",
            "Annunciation_Window", "MAPR", "g7327", "MAPL", "g7332", "rect7334",
            "WeatherBG", "rect5434", "rect5430", "error_windows"]) {
            elem = m.pfd.getElementById(key);
            if (elem != nil)
                m.pfd.getElementById(key).hide()
            else
                print(sprintf("Elements %s not found.", key));
        }

		m.nav1defl = 0;
		m.nav2defl = 0;
		setlistener("autopilot/settings/heading-bug-deg",
			func m.updateHdgTgt(), 1, 0);
		setlistener("autopilot/settings/target-altitude-ft",
			func m.updateAltTgt(), 1, 0);
		setlistener("autopilot/settings/target-speed-kt",
			func m.updateIasTgt(), 1, 0);
		setlistener("instrumentation/altimeter/setting-hpa",
			func() { m.updateQNH() }, 0, 0);
		setlistener("instrumentation/altimeter/setting-inhg",
			func() { m.updateQNH() }, 0, 0);
		setlistener("instrumentation/FarminTemp/baro-display-hpa",
			func() { m.updateQNH() }, 1, 0);
		setlistener("autopilot/settings/target-altitude-ft",
			func m.updateAltTgt(), 1, 0);
		return m;
	},

	updateAi: func(){
		var roll = getprop(
            "instrumentation/attitude-indicator/indicated-roll-deg");
		var pitch = getprop(
            "instrumentation/attitude-indicator/indicated-pitch-deg");
		if (getprop("instrumentation/attitude-indicator/serviceable") == 1
            and roll != nil and pitch != nil) {
			me.pfd.getElementById("ATTFAIL").hide();
			foreach(var key; ["layer4", "bankPointer"])
                me.pfd.getElementById(key).show();
		} else {
			me.pfd.getElementById("ATTFAIL").show();
			foreach(var key; ["layer4", "bankPointer"])
                me.pfd.getElementById(key).hide();
			return;
		};

		if (pitch > 80 ) pitch = 80;
		if (pitch < -80) pitch = -80;

		var RollR = -roll*D2R;

		var AP	= 57.5;
		var AN	= 27.5;
		var BP	= 37.5;
		var BN	= 40;

		var HLAPRN = math.sqrt(1/(math.pow(math.cos(RollR)/AP,2)+(math.pow(math.sin(RollR)/BN,2))));
		var HLANBN = math.sqrt(1/(math.pow(math.cos(RollR)/AN,2)+(math.pow(math.sin(RollR)/BN,2))));
		var HLAPBP = math.sqrt(1/(math.pow(math.cos(RollR)/AP,2)+(math.pow(math.sin(RollR)/BP,2))));
		var HLANBP = math.sqrt(1/(math.pow(math.cos(RollR)/AN,2)+(math.pow(math.sin(RollR)/BP,2))));

		var RAP	= ((roll > -90) and (roll <= 90));
		var RAN = ((roll <= -90) or (roll > 90));
		var RBP = (roll >= 0);
		var RBN = (roll < 0);
		if((pitch >= 0) and (RAP and RBN))
		{
			var limit = HLAPRN;
		}
		elsif((pitch >= 0) and (RAN and RBN))
		{
			var limit = HLANBN;
		}
		elsif((pitch >= 0)and (RAP and RBP))
		{
			var limit = HLAPBP;
		}
		elsif((pitch >= 0)and (RAN and RBP))
		{
			var limit = HLANBP;
		}
		elsif((pitch < 0) and (RAN and RBP))
		{
			var limit = HLAPRN;
		}
		elsif((pitch < 0) and (RAP and RBP))
		{
			var limit = HLANBN;
		}
		elsif((pitch < 0)and (RAN and RBN))
		{
			var limit = HLAPBP;
		}
		elsif((pitch < 0)and (RAP and RBN))
		{
			var limit = HLANBP;
		}

		if(pitch > limit)
		{
			var Hpitch = limit;
		}
		elsif(-pitch > limit)
		{
			var Hpitch = -limit;
		}
		else
		{
			var Hpitch = pitch;
		}

		me.Horizon.rot.setRotation(RollR, me.PitchScale.getCenter());
		me.Horizon.trans.setTranslation(0,Hpitch*6.8571428);

		me.HorizonLine.rot.setRotation(RollR, me.PitchScale.getCenter());
		me.HorizonLine.trans.setTranslation(0,pitch*6.8571428);
		me.PitchScale.rot.setRotation(RollR, me.PitchScale.getCenter());
		me.PitchScale.trans.setTranslation(0,pitch*6.8571428);

		var brot = me.bankPointer.getCenter();
		me.bankPointer.rot.setRotation(RollR,brot);
		me.bankPointerLineL.rot.setRotation(RollR,brot);
		me.bankPointerLineR.rot.setRotation(RollR,brot);

		if (RollR < 0) #top, right, bottom, left
		{
			me.bankPointerLineL.set("clip", "rect(0,1,1,0)"); #459,500
			me.bankPointerLineR.set("clip", "rect(0,459.500,768,0)");
		}
		elsif (RollR > 0)
		{
			me.bankPointerLineL.set("clip", "rect(0,1024,768,459.500)"); #459,500
			me.bankPointerLineR.set("clip", "rect(0,1,1,0)");
		}
		else
		{
			me.bankPointerLineL.set("clip", "rect(0,1024,768,459.500)"); #459,500
			me.bankPointerLineR.set("clip", "rect(0,459.500,768,0)");
		}
	},

	UpdateHeading: func {
		var hdg = getprop("instrumentation/heading-indicator/indicated-heading-deg");
		var hdgFail = getprop("instrumentation/heading-indicator/serviceable") == 0 or hdg == nil;
		if (hdgFail == 1) {
            hdg = 0;
            me.HDGFAIL.show();
            me.HDG.hide();
        } else {
            me.HDGFAIL.hide();
            me.HDG.show();
        }
        me.CompassRot.setRotation(-hdg*D2R);
        me.HDGVAL.setText(sprintf("%03.0f°", math.round(hdg)));

        var crsVisible = 0;
        if (getprop("instrumentation/nav[0]/serviceable") == 1
            and getprop("instrumentation/FarminTemp/cdi-display") == "nav1") {
            var deg = getprop("instrumentation/nav[0]/radials/selected-deg");
            var sel = getprop("instrumentation/nav[0]/radials/selected-deg");
            me.COMPASSNAV1.setRotation(sel*D2R);
            me.CRSVAL.setText(sprintf("%03.0f", sel));
            if (getprop("instrumentation/nav[0]/in-range") == 1 and
                getprop("instrumentation/nav[0]/cdi/serviceable") == 1) {
                me.NAV1CDI.setTranslation(-me.nav1defl, 0);
                me.nav1defl = getprop("instrumentation/nav[0]/heading-needle-deflection-norm") * 70;
                me.NAV1CDI.setTranslation(me.nav1defl, 0);
                me.NAV1CDI.show();
            } else {
                me.NAV1CDI.hide();
            }
            var tofromvalid =
                getprop("instrumentation/nav[0]/to-from/serviceable") == 1;
            me.NAV1TO.setVisible(tofromvalid and
                    getprop("instrumentation/nav[0]/to-flag") == 1);
            me.NAV1FROM.setVisible(tofromvalid and
                    getprop("/instrumentation/nav[0]/from-flag") == 1);
            me.COMPASSNAV1.show();
            crsVisible = 1;
        } else {
            me.COMPASSNAV1.hide();
        }
		if (getprop("instrumentation/nav[1]/serviceable") == 1
			and getprop("instrumentation/FarminTemp/cdi-display") == "nav2") {
			var deg = getprop("instrumentation/nav[1]/radials/selected-deg");
		    var sel = getprop("instrumentation/nav[1]/radials/selected-deg");
		    me.COMPASSNAV2.setRotation(sel*D2R);
            me.CRSVAL.setText(sprintf("%03.0f", sel));
            if (getprop("instrumentation/nav[1]/in-range") == 1 and
                getprop("instrumentation/nav[1]/cdi/serviceable") == 1) {
                me.NAV2CDI.setTranslation(-me.nav2defl, 0);
                me.nav2defl = getprop("instrumentation/nav[1]/heading-needle-deflection-norm") * 70;
                me.NAV2CDI.setTranslation(me.nav2defl, 0);
                me.NAV2CDI.show();
            } else {
                me.NAV2CDI.hide();
            }
            var tofromvalid =
                getprop("instrumentation/nav[1]/to-from/serviceable") == 1;
            me.NAV2TO.setVisible(tofromvalid and
                    getprop("instrumentation/nav[1]/to-flag") == 1);
            me.NAV2FROM.setVisible(tofromvalid and
                    getprop("/instrumentation/nav[1]/from-flag") == 1);
            me.COMPASSNAV2.show();
            crsVisible = 1;
        } else {
            me.COMPASSNAV2.hide();
        }
		if (getprop("instrumentation/gps/serviceable") == 1
			and getprop("instrumentation/FarminTemp/cdi-display") == "gps") {
            me.COMPASSGPS.show();
        } else {
            me.COMPASSGPS.hide();
        }
        me.CRS.setVisible(crsVisible);
		if (getprop("instrumentation/adf/serviceable") == 1
			and getprop("instrumentation/FarminTemp/show-adf") == 1) {
            me.COMPASSADF.show();
        } else {
            me.COMPASSADF.hide();
        }
	},

	updateSpeed: func()
	{
		speed = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
		tas = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
		if(getprop("/instrumentation/airspeed-indicator/serviceable") == 1 and speed != nil) {
			me.data.speed = speed;
			var Offset1 = 0;
			var Offset10 = 0;

			if (speed < 20)
			{
				var speed = 20;
				me.LindSpeed.set("clip", "rect(114px, 239px, 284,5px, 154px)");
			}
			elsif (speed >= 20 and  speed < 50)
			{
				me.LindSpeed.set("clip", sprintf("rect(114px, 239px, %1.0fpx, 154px)", math.floor(284.5 + ((speed-20) * 5.71225) ) ) );
			}
			else
			{
				me.LindSpeed.set("clip", "rect(114px, 239px, 455px, 154px)");
			};

			if (speed > 20)
			{
				me.LindSpeed.setTranslation(0,speed*5.71225);
			}else{
				me.LindSpeed.setTranslation(0,114,245);
			};

			var speed1		= math.mod(speed,10);
			var speed10		= int(math.mod(speed/10,10));
			var speed100	= int(math.mod(speed/100,10));
			var speed0_1 	= speed1 - int(speed1);
			if (speed1 >= 9)
			{
				var speed10 += speed0_1;
			}

			if (speed1 >= 9 and speed10 >= 9)
			{
				var speed100 += speed0_1;
			}

			if(speed >= 10)
			{
				var Offset1 = 10;
			}
			if(speed >= 100)
			{
				var Offset10 = 10;
			}
			me.LindSpeed.setTranslation(0,speed*5.71225);
			me.SpeedtLint1.setTranslation(0,(speed1+Offset1)*36);
			me.SpeedtLint10.setTranslation(0,(speed10+Offset10)*36);
			me.SpeedtLint100.setTranslation(0,(speed100)*36);
			me.pfd.getElementById("TASVAL").setText(sprintf("%3.0f", tas));
			me.pfd.getElementById("g7050").hide();
			foreach(var key; ["SpeedtLint", "LindSpeed", "path4410"]) me.pfd.getElementById(key).show();
		} else {
			me.pfd.getElementById("TASVAL").setText("---");
			me.pfd.getElementById("g7050").show();
			foreach(var key; ["SpeedtLint", "LindSpeed", "path4410"]) me.pfd.getElementById(key).hide();
		}
	},
	updateSpeedTrend: func(Speedtrent)
	{
		me.data.speedTrent;

	},
	updateSlipSkid: func()
	{
		var slipskid = getprop("/instrumentation/slip-skid-ball/indicated-slip-skid");
		if (getprop("/instrumentation/slip-skid-ball/serviceable") and slipskid != nil) {
			me.SlipSkid.setTranslation(slipskid*5.73,0);
			me.pfd.getElementById("SlipSkid").show();
		} else {
			me.pfd.getElementById("SlipSkid").hide();
		}
	},

	updateAlt: func()
	{
		var Alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		if(getprop("/instrumentation/altimeter/serviceable") == 1 and Alt != nil and Alt > -1000 and Alt< 1000000)
		{
			var Offset10 = 0;
			var Offset100 = 0;
			var Offset1000 = 0;
			if(Alt< 0)
			{
				var Ne = 1;
				var Alt= -Alt
			}
			else
			{
				var Ne = 0;
			}

			var Alt10		= math.mod(Alt,100);
			var Alt100		= int(math.mod(Alt/100,10));
			var Alt1000		= int(math.mod(Alt/1000,10));
			var Alt10000	= int(math.mod(Alt/10000,10));
			var Alt20 		= math.mod(Alt10,20)/20;
			if (Alt10 >= 80)
			{
				var Alt100 += Alt20
			};

			if (Alt10 >= 80 and Alt100 >= 9)
			{
				var Alt1000 += Alt20
			};

			if (Alt10 >= 80 and Alt100 >= 9 and Alt1000 >= 9)
			{
				var Alt10000 += Alt20
			};

			if (Alt> 100)
			{
				var Offset10 = 100;
			}

			if (Alt> 1000)
			{
				var Offset100 = 10;
			}

			if (Alt> 10000)
			{
				var Offset1000 = 10;
			}

			if(!Ne)
			{
				me.AltLint10.setTranslation(0,(Alt10+Offset10)*1.2498);
				me.AltLint100.setTranslation(0,(Alt100+Offset100)*30);
				me.AltLint1000.setTranslation(0,(Alt1000+Offset1000)*36);
				me.AltLint10000.setTranslation(0,(Alt10000)*36);
				me.LintAlt.setTranslation(0,(math.mod(Alt,100))*0.57375);
				var altCentral = (int(Alt/100)*100);
			}
			elsif(Ne)
			{
				me.AltLint10.setTranslation(0,(Alt10+Offset10)*-1.2498);
				me.AltLint100.setTranslation(0,(Alt100+Offset100)*-30);
				me.AltLint1000.setTranslation(0,(Alt1000+Offset1000)*-36);
				me.AltLint10000.setTranslation(0,(Alt10000)*-36);
				me.LintAlt.setTranslation(0,(math.mod(Alt,100))*-0.57375);
				var altCentral = -(int(Alt/100)*100);
			}
			me["AltBigC"].setText("");
			me["AltSmallC"].setText("");
			var placeInList = [1,2,3,4,5,6];
			foreach(var place; placeInList)
			{
				var altUP = altCentral + (place*100);
				var offset = -30.078;
				if (altUP < 0)
				{
					var altUP = -altUP;
					var prefix = "-";
					var offset += 15.039;
				}
				else
				{
					var prefix = "";
				}
				if(altUP == 0)
				{
					var AltBigUP	= "";
					var AltSmallUP	= "0";

				}
				elsif(math.mod(altUP,500) == 0 and altUP != 0)
				{
					var AltBigUP	= sprintf(prefix~"%1d", altUP);
					var AltSmallUP	= "";
				}
				elsif(altUP < 1000 and (math.mod(altUP,500)))
				{
					var AltBigUP	= "";
					var AltSmallUP	= sprintf(prefix~"%1d", int(math.mod(altUP,1000)));
					var offset = -30.078;
				}
				elsif((altUP < 10000) and (altUP >= 1000) and (math.mod(altUP,500)))
				{
					var AltBigUP	= sprintf(prefix~"%1d", int(altUP/1000));
					var AltSmallUP	= sprintf("%1d", int(math.mod(altUP,1000)));
					var offset += 15.039;
				}
				else
				{
					var AltBigUP	= sprintf(prefix~"%1d", int(altUP/1000));
					var mod = int(math.mod(altUP,1000));
					var AltSmallUP	= sprintf("%1d", mod);
					var offset += 30.078;
				}

				me["AltBigU"~place].setText(AltBigUP);
				me["AltSmallU"~place].setText(AltSmallUP);
				me["AltSmallU"~place].setTranslation(offset,0);
				var altDOWN = altCentral - (place*100);
				var offset = -30.078;
				if (altDOWN < 0)
				{
					var altDOWN = -altDOWN;
					var prefix = "-";
					var offset += 15.039;
				}
				else
				{
					var prefix = "";
				}
				if(altDOWN == 0)
				{
					var AltBigDOWN	= "";
					var AltSmallDOWN	= "0";

				}
				elsif(math.mod(altDOWN,500) == 0 and altDOWN != 0)
				{
					var AltBigDOWN	= sprintf(prefix~"%1d", altDOWN);
					var AltSmallDOWN	= "";
				}
				elsif(altDOWN < 1000 and (math.mod(altDOWN,500)))
				{
					var AltBigDOWN	= "";
					var AltSmallDOWN	= sprintf(prefix~"%1d", int(math.mod(altDOWN,1000)));
					var offset = -30.078;
				}
				elsif((altDOWN < 10000) and (altDOWN >= 1000) and (math.mod(altDOWN,500)))
				{
					var AltBigDOWN	= sprintf(prefix~"%1d", int(altDOWN/1000));
					var AltSmallDOWN	= sprintf("%1d", int(math.mod(altDOWN,1000)));
					var offset += 15.039;
				}
				else
				{
					var AltBigDOWN	= sprintf(prefix~"%1d", int(altDOWN/1000));
					var mod = int(math.mod(altDOWN,1000));
					var AltSmallDOWN	= sprintf("%1d", mod);
					var offset += 30.078;
				}
				me["AltBigD"~place].setText(AltBigDOWN);
				me["AltSmallD"~place].setText(AltSmallDOWN);
				me["AltSmallD"~place].setTranslation(offset,0);
			}
			me.pfd.getElementById("g7272").hide();
			foreach(var key; ["AltLint10", "AltLint100", "AltLint1000", "AltLint10000", "path4400", "AltLint", "LintAlt"]) me.pfd.getElementById(key).show();
		} else {
			me.pfd.getElementById("g7272").show();
			foreach(var key; ["AltLint10", "AltLint100", "AltLint1000", "AltLint10000", "path4400", "AltLint", "LintAlt"]) me.pfd.getElementById(key).hide();
		}
	},

	updateVSI: func()
	{
		var VSI = getprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm");
		if(getprop("/instrumentation/vertical-speed-indicator/serviceable") == 1 and VSI != nil) {
			var VSIOffset = -0.034875*math.max(-4250, math.min(4250, VSI));
			if (math.abs(VSI) < 100) {
				var VSIText = "";
			} elsif (math.abs(VSI) > 10000) {
				var VSIText = "----";
			} else {
				var VSIText = sprintf("%1d",int(VSI/50)*50);
			}
			me.VSIText.setText(VSIText);
			me.VSI.setTranslation(0,VSIOffset);
			me.pfd.getElementById("g7288").hide();
			foreach(var key; ["VSI"]) me.pfd.getElementById(key).show();
		} else {
			me.pfd.getElementById("g7288").show();
			foreach(var key; ["VSI"]) me.pfd.getElementById(key).hide();
		};
	},

	updateMarkers: func(marker)
	{
		if(marker == 0)
		{
			me.Marker.hide();
		}
		if(marker == 1) #OM
		{
			me.Marker.show();
			me.MarkerBG.setColorFill(0.603921569,0.843137255,0.847058824);
			me.MarkerText.setText('O');
		}
		if(marker == 2) #MM
		{
			me.Marker.show();
			me.MarkerBG.setColorFill(1,0.870588235,0.11372549);
			me.MarkerText.setText('M');
		}
		if(marker == 3) #IM
		{
			me.Marker.show();
			me.MarkerBG.setColorFill(1,1,1);
			me.MarkerText.setText('I');
		}
	},
	updateGS: func {
        if (getprop("instrumentation/FarminTemp/cdi-display") == "nav1"
            and getprop("instrumentation/nav[0]/gs/serviceable") == 1
            and getprop("instrumentation/nav[0]/has-gs") == 1)
            var prefix = "instrumentation/nav[0]/"
        elsif (getprop("instrumentation/FarminTemp/cdi-display") == "nav2"
            and getprop("instrumentation/nav[1]/gs/serviceable") == 1
            and getprop("instrumentation/nav[1]/has-gs") == 1)
            var prefix = "instrumentation/nav[1]/";
        else {
            me.GS.hide();
            return;
        }
        me.GS.show();
        var defl = getprop(prefix~"gs-needle-deflection-norm");
        if (getprop(prefix~"gs-in-range") == 1 and defl != nil) {
            me.GSI.show();
            me.GSI.setTranslation(0, -86.984 * defl);
        } else
            me.GSI.hide();
	},

	updateIasTgt: func me.IASTGTVAL.setText(sprintf(
		"%3.0f", getprop("autopilot/settings/target-speed-kt"))),
	updateHdgTgt: func {
        var bug = getprop("autopilot/settings/heading-bug-deg");
        me.HSB.setRotation(bug*D2R);
        me.HDGTGTVAL.setText(sprintf("%03.0f", bug));
    },
	updateAltTgt: func {
		var alttgt = getprop("autopilot/settings/target-altitude-ft");
		var neg = math.sgn(alttgt);
		alttgt = math.abs(alttgt);
		me.pfd.getElementById("ALTTGTVAL0").setText(
			sprintf("%02.0f", neg * math.floor(alttgt / 1000)));
		me.pfd.getElementById("ALTTGTVAL1").setText(
			sprintf("%03.0f", math.mod(alttgt, 1000)));
	},
	updateQNH: func() {
		if (getprop("instrumentation/FarminTemp/baro-display-hpa") == 1)
			qnh = sprintf("%4.0fHPA", getprop("instrumentation/altimeter/setting-hpa"))
		else
			qnh = sprintf("%5.2fIN", getprop("instrumentation/altimeter/setting-inhg"));
		me.pfd.getElementById("QNHVAL").setText(qnh);
	},
	updateControls: func() {
		me.pfd.getElementById("THRL").setText(sprintf("%3i", (getprop("/controls/engines/engine[0]/throttle") or 0) * 100));
		me.pfd.getElementById("THRR").setText(sprintf("%3i", (getprop("/controls/engines/engine[1]/throttle") or 0) * 100));
		me.pfd.getElementById("ADVL").setText(sprintf("%3i", (getprop("/controls/engines/engine[0]/propeller-pitch") or 0) * 100));
		me.pfd.getElementById("ADVR").setText(sprintf("%3i", (getprop("/controls/engines/engine[1]/propeller-pitch") or 0) * 100));
		me.pfd.getElementById("MIXL").setText(sprintf("%3i", (getprop("/controls/engines/engine[0]/mixture") or 0) * 100));
		me.pfd.getElementById("MIXR").setText(sprintf("%3i", (getprop("/controls/engines/engine[1]/mixture") or 0) * 100));
		me.pfd.getElementById("ELEVATOR").setText(sprintf("%+4i", (getprop("/controls/flight/elevator") or 0) * 100));
		me.pfd.getElementById("AILERON").setText(sprintf("%+4i", (getprop("/controls/flight/aileron") or 0) * 100));
		me.pfd.getElementById("RUDDER").setText(sprintf("%+4i", (getprop("/controls/flight/rudder") or 0) * 100));
	},
	updatePerformance: func() {
		me.pfd.getElementById("TRSL").setText(sprintf("%3i", (getprop("/engines/engine[0]/thrust-lbs") or 0)));
		me.pfd.getElementById("TRSR").setText(sprintf("%3i", (getprop("/engines/engine[1]/thrust-lbs") or 0)));
		me.pfd.getElementById("FFLL").setText(sprintf("%3i", getprop("/engines/engine[0]/fuel-flow-gph")));
		me.pfd.getElementById("FFLR").setText(sprintf("%3i", getprop("/engines/engine[1]/fuel-flow-gph")));
	},
};
